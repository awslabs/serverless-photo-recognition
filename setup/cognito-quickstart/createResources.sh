#!/usr/bin/env bash

ROOT_NAME=$1

# Replace with your 12-digit AWS account ID (e.g., 123456789012)
AWS_ACCOUNT=$2
ROLE_NAME_PREFIX=$ROOT_NAME
POOL_NAME=$ROOT_NAME
IDENTITY_POOL_NAME=$ROOT_NAME
REGION=$3
PICTURE_BUCKET_NAME=$4
DELETE_SCRIPT=$5

# Create a Cognito Identity and Set roles
aws cognito-identity create-identity-pool --identity-pool-name $IDENTITY_POOL_NAME --allow-unauthenticated-identities --region ${REGION}| grep IdentityPoolId | awk '{print $2}' | xargs |sed -e 's/^"//'  -e 's/"$//' -e 's/,$//' > /tmp/poolId
identityPoolId=$(cat /tmp/poolId)
echo $identityPoolId > /tmp/identityPoolId

cat << EOF >> ${DELETE_SCRIPT}
echo "Deleting Identity Pool: " $identityPoolId
aws cognito-identity delete-identity-pool --identity-pool-id $identityPoolId  --region ${REGION}

EOF

# Create an IAM role for unauthenticated users
cat unauthrole-trust-policy.json | sed 's/IDENTITY_POOL/'$identityPoolId'/' > /tmp/unauthrole-trust-policy.json
aws iam create-role --role-name $ROLE_NAME_PREFIX-unauthenticated-role --assume-role-policy-document file:///tmp/unauthrole-trust-policy.json --region ${REGION}
aws iam put-role-policy --role-name $ROLE_NAME_PREFIX-unauthenticated-role --policy-name CognitoPolicy --policy-document file://unauthrole.json --region ${REGION}
cat << EOF >> ${DELETE_SCRIPT}
echo "Detaching " $ROLE_NAME_PREFIX-unauthenticated-role"'s policies and deleting role"
aws iam delete-role-policy --role-name $ROLE_NAME_PREFIX-unauthenticated-role --policy-name CognitoPolicy --region ${REGION}
aws iam delete-role --role-name $ROLE_NAME_PREFIX-unauthenticated-role --region ${REGION}

EOF

# Create an IAM role for authenticated users
cat authrole-trust-policy.json | sed 's/IDENTITY_POOL/'$identityPoolId'/' > /tmp/authrole-trust-policy.json
aws iam create-role --role-name $ROLE_NAME_PREFIX-authenticated-role --assume-role-policy-document file:///tmp/authrole-trust-policy.json --region ${REGION}
cat authrole.json | sed 's/TABLE_NAME/'$TABLE_NAME'/' | sed 's/ACCOUNT_NUMBER/'$AWS_ACCOUNT'/' | sed 's/REGION/'$REGION'/' | sed 's/PICTURES_BUCKET_NAME_REPLACE_ME/'${PICTURE_BUCKET_NAME}'/'> /tmp/authrole.json
aws iam put-role-policy --role-name $ROLE_NAME_PREFIX-authenticated-role --policy-name CognitoPolicy --policy-document file:///tmp/authrole.json --region ${REGION}
cat << EOF >> ${DELETE_SCRIPT}
echo "Detaching " $ROLE_NAME_PREFIX-authenticated-role"'s policies and deleting role"
aws iam delete-role-policy --role-name $ROLE_NAME_PREFIX-authenticated-role --policy-name CognitoPolicy --region ${REGION}
aws iam delete-role --role-name $ROLE_NAME_PREFIX-authenticated-role --region ${REGION}

EOF

# Create the user pool
aws cognito-idp create-user-pool --pool-name $POOL_NAME --auto-verified-attributes email --schema Name=email,Required=true --policies file://user-pool-policy.json --region $REGION > /tmp/$POOL_NAME-create-user-pool
userPoolId=$(grep -E '"Id":' /tmp/$POOL_NAME-create-user-pool | awk -F'"' '{print $4}')
echo $userPoolId > /tmp/userPoolId
cat << EOF >> ${DELETE_SCRIPT}
echo "Deleting user pool: " + ${userPoolId}
aws cognito-idp delete-user-pool --user-pool-id ${userPoolId} --region ${REGION}

EOF

# Create the user pool client
aws cognito-idp create-user-pool-client --user-pool-id $userPoolId --no-generate-secret --client-name webapp --region $REGION > /tmp/$POOL_NAME-create-user-pool-client --region ${REGION}
userPoolClientId=$(grep -E '"ClientId":' /tmp/$POOL_NAME-create-user-pool-client | awk -F'"' '{print $4}')
echo ${userPoolClientId} > /tmp/userPoolClientId

# Add the user pool and user pool client id to the identity pool
aws cognito-identity update-identity-pool --allow-unauthenticated-identities --identity-pool-id $identityPoolId --identity-pool-name $IDENTITY_POOL_NAME --cognito-identity-providers ProviderName=cognito-idp.$REGION.amazonaws.com/$userPoolId,ClientId=$userPoolClientId --region $REGION

# Update cognito identity with the roles
# If this command gives you an error, associate the roles manually
aws cognito-identity set-identity-pool-roles --identity-pool-id $identityPoolId --roles authenticated=arn:aws:iam::$AWS_ACCOUNT:role/$ROLE_NAME_PREFIX-authenticated-role,unauthenticated=arn:aws:iam::$AWS_ACCOUNT:role/$ROLE_NAME_PREFIX-unauthenticated-role --region $REGION

