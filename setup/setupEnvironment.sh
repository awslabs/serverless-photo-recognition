#!/usr/bin/env bash

ROOT_NAME=$(date +%Y%m%d%H%M%S)
echo "Using the following 'root name' for your resources, such as S3 bucket: " ${ROOT_NAME}

BUCKET_NAME=rekognition-${ROOT_NAME}
REGION=us-east-1
EXTERNAL_IP_ADDRESS=$(curl ipinfo.io/ip)
ACCOUNT_NUMBER=$(aws ec2 describe-security-groups --group-names 'Default' --query 'SecurityGroups[0].OwnerId' --output text)
COGNITO_POOL_NAME_REPLACE_ME=${ROOT_NAME}rek
API_GATEWAY_NAME=cognitorek-${ROOT_NAME}
DELETE_SCRIPT=/tmp/deleteAWSResources${ROOT_NAME}.sh

# Lambda
JAR_LOCATION=../build/libs/rekognition-rest-1.0-SNAPSHOT.jar
FUNCTION_REK_SEARCH=rekognition-search-picture-${ROOT_NAME}
FUNCTION_REK_ADD=rekognition-add-picture-${ROOT_NAME}
FUNCTION_REK_DEL=rekognition-del-picture-${ROOT_NAME}
FUNCTION_REK_SEARCH_HANDLER=com.budilov.SearchPhotosHandler
FUNCTION_REK_ADD_HANDLER=com.budilov.AddPhotoLambda
FUNCTION_REK_DEL_HANDLER=com.budilov.RemovePhotoLambda

# IAM
ROLE_NAME=lambda-to-es-rek-s3-${ROOT_NAME}

# ES
ES_DOMAIN_NAME=rekognition${ROOT_NAME}

# Start the creation of the deletion script
touch ${DELETE_SCRIPT}
chmod 755 ${DELETE_SCRIPT}
cat << EOF >> ${DELETE_SCRIPT}
#!/usr/bin/env bash

read -p "This will remove (most) all of the previously created AWS resources. Are you sure? " -n 1 -r
echo
if [[ ! \$REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

EOF

# Methods
createLambdaFunction() {
   if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
     echo "No parameters were passed"
     exit -1
   fi

    aws lambda create-function --region $1 \
        --function-name $2 \
        --zip-file fileb://$3 \
        --role arn:aws:iam::${ACCOUNT_NUMBER}:role/${ROLE_NAME} \
        --handler $4 \
        --runtime java8 \
        --memory-size 192 \
        --timeout 20

cat << EOF >> ${DELETE_SCRIPT}
echo "Deleting the " $2 " Lambda function"
aws lambda delete-function --function-name $2

EOF

}

updateFunction() {
   if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
     echo "No parameters were passed"
     exit -1
   fi

    aws lambda update-function-code \
    --region $1 \
    --function-name $2 \
    --zip-file fileb://$3
}

# Setup the Cognito quickstart app and resources
echo "Creating the Cognito resources"
cd ./cognito-quickstart/
chmod 755 createResources.sh
./createResources.sh ${COGNITO_POOL_NAME_REPLACE_ME} ${ACCOUNT_NUMBER} ${REGION} ${BUCKET_NAME} ${DELETE_SCRIPT}
USER_POOL_ID=$(cat /tmp/userPoolId)
COGNITO_POOL_ID=$(cat /tmp/identityPoolId)
echo "Cognito User Pool Id: " ${USER_POOL_ID}
echo "Cognito Identity Id:  " ${COGNITO_POOL_ID}
cd ..

POOL_ARN_REPLACE_ME=arn:aws:cognito-idp:${REGION}:${ACCOUNT_NUMBER}:userpool/${USER_POOL_ID}

# Create IAM roles
aws iam create-role --role-name ${ROLE_NAME} --assume-role-policy-document file://s3-to-es-role-trust-relationship.json
aws iam attach-role-policy --role-name ${ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/AmazonESFullAccess
aws iam attach-role-policy --role-name ${ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/AmazonRekognitionFullAccess
aws iam attach-role-policy --role-name ${ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam attach-role-policy --role-name ${ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess

# Creating the role & role policy deletion
cat << EOF >> ${DELETE_SCRIPT}
echo "Detaching ${ROLE_NAME}'s policies and deleting role"
aws iam detach-role-policy --role-name ${ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/AmazonESFullAccess
aws iam detach-role-policy --role-name ${ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/AmazonRekognitionFullAccess
aws iam detach-role-policy --role-name ${ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam detach-role-policy --role-name ${ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess
aws iam delete-role --role-name ${ROLE_NAME}

EOF


# Create the photos bucket
aws s3 mb s3://${BUCKET_NAME}/ --region ${REGION}
aws s3api put-bucket-cors --bucket ${BUCKET_NAME} --cors-configuration file://s3-bucket-cors-configuration.json

# Create delete bucket code
cat << EOF >> ${DELETE_SCRIPT}
echo "Removing the bucket"
aws s3 rm s3://${BUCKET_NAME} --recursive
aws s3 rb s3://${BUCKET_NAME}

EOF
# Build and deploy Lambda functions
## Build
cd ..
chmod 755 gradlew
./gradlew build
cd setup

## Create and deploy
createLambdaFunction ${REGION} ${FUNCTION_REK_ADD} ${JAR_LOCATION} ${FUNCTION_REK_ADD_HANDLER} > /tmp/addlambdaoutput
REKOGNITION_ADD_FUNCTION_ARN=$(grep FunctionArn /tmp/addlambdaoutput | awk '{print $2}' | xargs |sed -e 's/^"//'  -e 's/"$//' -e 's/,$//')

createLambdaFunction ${REGION} ${FUNCTION_REK_DEL} ${JAR_LOCATION} ${FUNCTION_REK_DEL_HANDLER} > /tmp/dellambdaoutput
REKOGNITION_DELETE_FUNCTION_ARN=$(grep FunctionArn /tmp/dellambdaoutput | awk '{print $2}' | xargs |sed -e 's/^"//'  -e 's/"$//' -e 's/,$//')

createLambdaFunction ${REGION} ${FUNCTION_REK_SEARCH} ${JAR_LOCATION} ${FUNCTION_REK_SEARCH_HANDLER} > /tmp/searchlambdaoutput
REKOGNITION_SEARCH_FUNCTION_ARN=$(grep FunctionArn /tmp/searchlambdaoutput | awk '{print $2}' | xargs |sed -e 's/^"//'  -e 's/"$//' -e 's/,$//')

# Setup the S3 events
echo "Setting up the S3 Lambda events"

echo "Adding the ADD event Lambda permissions"
aws lambda add-permission \
    --function-name ${FUNCTION_REK_ADD} \
    --region ${REGION} \
    --statement-id ${ROOT_NAME}-rekognition \
    --action "lambda:InvokeFunction" \
    --principal s3.amazonaws.com \
    --source-arn arn:aws:s3:::${BUCKET_NAME} \
    --source-account ${ACCOUNT_NUMBER}

echo "Adding the DEL event Lambda permissions"
aws lambda add-permission \
    --function-name ${FUNCTION_REK_DEL} \
    --region ${REGION} \
    --statement-id ${ROOT_NAME}-rekognition \
    --action "lambda:InvokeFunction" \
    --principal s3.amazonaws.com \
    --source-arn arn:aws:s3:::${BUCKET_NAME} \
    --source-account ${ACCOUNT_NUMBER}

echo "Preparing the S3 Notifications json definitions file"
cat s3-notifications.json |
    sed 's#REKOGNITION_DEL_FUNCTION_ARN_REPLACE_ME#'${REKOGNITION_DELETE_FUNCTION_ARN}'#g' |
    sed 's#REKOGNITION_ADD_FUNCTION_ARN_REPLACE_ME#'${REKOGNITION_ADD_FUNCTION_ARN}'#g' > /tmp/s3-notifications.json

echo "Creating the events"
aws s3api put-bucket-notification-configuration --bucket ${BUCKET_NAME} --notification-configuration file:///tmp/s3-notifications.json

# Setup Elasticsearch
echo "Setup Elasticsearch with a domain of ${ES_DOMAIN_NAME}"
aws es create-elasticsearch-domain --domain-name ${ES_DOMAIN_NAME} --elasticsearch-version 5.1 --elasticsearch-cluster-config InstanceType=t2.small.elasticsearch,InstanceCount=1 --ebs-options EBSEnabled=true,VolumeType=standard,VolumeSize=10
cat elasticsearch_service_policy.json |
    sed 's#ACCOUNT_NAME_REPLACE_ME#'${ACCOUNT_NUMBER}'#g' |
    sed 's#REGION_REPLACE_ME#'${REGION}'#g' |
    sed 's#ROLE_NAME_REPLACE_ME#'${ROLE_NAME}'#g' |
    sed 's#ES_DOMAIN_NAME_REPLACE_ME#'${ES_DOMAIN_NAME}'#g' |
    sed 's#EXTERNAL_IP_ADDRESS_REPLACE_ME#'${EXTERNAL_IP_ADDRESS}'#g' > /tmp/elasticsearch_service_policy.json
aws es update-elasticsearch-domain-config --domain-name ${ES_DOMAIN_NAME} --access-policies file:///tmp/elasticsearch_service_policy.json

## We need the endpoint url now, but the ES domain is most-likely processing right now. Let's wait until it finishes
while [ 'None' == $(aws es describe-elasticsearch-domain --domain-name ${ES_DOMAIN_NAME} --query "DomainStatus.Endpoint" --output text) ];
do
    echo "Waiting for the ES domain ${ES_DOMAIN_NAME} to finish processing. Sleeping..."
    sleep 30
done

ES_ENDPOINT=$(aws es describe-elasticsearch-domain --domain-name ${ES_DOMAIN_NAME} --query "DomainStatus.Endpoint" --output text)
echo "Got the ES endpoint: ${ES_ENDPOINT}"

# Create delete ES domain
cat << EOF >> ${DELETE_SCRIPT}
echo "Deleting the ES domain"
aws es delete-elasticsearch-domain --domain-name ${ES_DOMAIN_NAME}

EOF

# Replace all of the property values in Properties.kt
sed  -i.tmp 's#REGION_REPLACE_ME#'${REGION}'#g' ../src/main/kotlin/com/budilov/Properties.kt
sed  -i.tmp 's#ACCOUNT_REPLACE_ME#'${ACCOUNT_NUMBER}'#g' ../src/main/kotlin/com/budilov/Properties.kt
sed  -i.tmp 's#COGNITO_POOL_ID_REPLACE_ME#'${COGNITO_POOL_ID}'#g' ../src/main/kotlin/com/budilov/Properties.kt
sed  -i.tmp 's#USER_POOL_ID_REPLACE_ME#'${USER_POOL_ID}'#g' ../src/main/kotlin/com/budilov/Properties.kt
sed  -i.tmp 's#ES_SERVICE_URL_REPLACE_ME#'${ES_ENDPOINT}'#g' ../src/main/kotlin/com/budilov/Properties.kt
sed  -i.tmp 's#BUCKET_REPLACE_ME#'${BUCKET_NAME}'#g' ../src/main/kotlin/com/budilov/Properties.kt

# Build the code again and update all of the lambda functions
cd ..
./gradlew build
cd setup
updateFunction ${REGION} ${FUNCTION_REK_ADD} ${JAR_LOCATION}
updateFunction ${REGION} ${FUNCTION_REK_DEL} ${JAR_LOCATION}
updateFunction ${REGION} ${FUNCTION_REK_SEARCH} ${JAR_LOCATION}
# Restore the Properties file

# Import your API Gateway Swagger template. This command can run after the Cognito User Pool is created
## First substitute values in the swagger file: COGNITO_POOL_NAME_REPLACE_ME,
## POOL_ARN_REPLACE_ME, REKOGNITION_ADD_FUNCTION, REKOGNITION_DELETE_FUNCTION, REKOGNITION_SEARCH_FUNCTION
echo "Preparing the swagger template. REGION: " ${REGION} " COGNITO_POOL_NAME: " ${COGNITO_POOL_NAME_REPLACE_ME} " POOL_ARN_REPLACE_ME: " ${POOL_ARN_REPLACE_ME} " REKOGNITION_SEARCH_FUNCTION_ARN: " ${REKOGNITION_SEARCH_FUNCTION_ARN}
cat apigateway-swagger.json |
    sed 's#REGION_REPLACE_ME#'${REGION}'#g' |
    sed 's#COGNITO_POOL_NAME_REPLACE_ME#'${COGNITO_POOL_NAME_REPLACE_ME}'#g' |
    sed 's#POOL_ARN_REPLACE_ME#'${POOL_ARN_REPLACE_ME}'#g' |
    sed 's#API_GATEWAY_NAME_REPLACE_ME#'${API_GATEWAY_NAME}'#g' |
    sed 's#REKOGNITION_SEARCH_FUNCTION_ARN_REPLACE_ME#'${REKOGNITION_SEARCH_FUNCTION_ARN}'#g' > /tmp/apigateway-swagger.json

echo "Importing the swagger template"
aws apigateway import-rest-api --body 'file:///tmp/apigateway-swagger.json' --region ${REGION} > /tmp/apigateway-import-api
GATEWAY_ID=$(cat /tmp/apigateway-import-api | grep id | awk '{print $2}' | xargs |sed -e 's/^"//'  -e 's/"$//' -e 's/,$//')

## Deploy to 'prd' stage
echo "Deploying the gateway with id of " ${GATEWAY_ID} " to prd"
aws apigateway create-deployment --rest-api-id ${GATEWAY_ID} --stage-name prod
API_GATEWAY_URL="https://${GATEWAY_ID}.execute-api.${REGION}.amazonaws.com/prod"

## Create a script that will remove (most) all of the AWS resources created
cat << EOF >> ${DELETE_SCRIPT}
echo "Deleting API Gateway"
aws apigateway delete-rest-api --rest-api-id ${GATEWAY_ID}

EOF

## get the JWT_ID_TOKEN
USERNAME=$(cat /dev/urandom | env LC_CTYPE=C tr -dc "a-zA-Z0-9" | fold -w 8 | head -n 1)
PASSWORD=$(cat /dev/urandom | env LC_CTYPE=C tr -dc "a-zA-Z0-9@#$%^&()_+~" | fold -w 16 | head -n 1)
#USERNAME="zeke"
#PASSWORD="P@ssword1"

#echo 'username: ' ${USERNAME}
#echo 'password: ' ${PASSWORD}

#USER_POOL_ID="us-east-1_ESkLVL2Vp"
CLIENT_ID=$(aws cognito-idp list-user-pool-clients --user-pool-id ${USER_POOL_ID} --max-results 3 --query UserPoolClients[0].ClientId --output text)

# 1.5 Enable sign-in API for server-based authentication (ADMIN_NO_SRP_AUTH)
SRP_AUTH_ENABLED=$(aws cognito-idp describe-user-pool-client --user-pool-id $USER_POOL_ID --client-id $CLIENT_ID --query '[contains(UserPoolClient.ExplicitAuthFlows,`ADMIN_NO_SRP_AUTH`)]' --output text)

if [ ! ${SRP_AUTH_ENABLED} ]; then
aws cognito-idp update-user-pool-client --user-pool-id ${USER_POOL_ID} --client-id ${CLIENT_ID}  --explicit-auth-flows ADMIN_NO_SRP_AUTH
echo "enabled"
else
echo "already enabled"
fi

# 2. sign-up a user

aws cognito-idp sign-up --client-id ${CLIENT_ID} --username ${USERNAME} --password ${PASSWORD} --user-attributes '[ { "Name": "email", "Value": "first.last@domain.com" }, { "Name": "phone_number", "Value": "+12485551212" }]'

# 2.5 confirm user
aws cognito-idp admin-confirm-sign-up --user-pool-id ${USER_POOL_ID} --username ${USERNAME}

#3. begin auth flow
cat << EOF > /tmp/authflow.json
{ "AuthFlow": "ADMIN_NO_SRP_AUTH", "AuthParameters": { "USERNAME": "${USERNAME}", "PASSWORD": "${PASSWORD}" } }
EOF

JWT_ID_TOKEN=$(aws cognito-idp admin-initiate-auth  --user-pool-id ${USER_POOL_ID} --client-id ${CLIENT_ID} --cli-input-json file:///tmp/authflow.json --query AuthenticationResult.IdToken --output text)

echo "JWT_ID_TOKEN: " ${JWT_ID_TOKEN}


echo "------------"
echo "You're done!"
echo "------------"
echo "These are you configured values:"
grep "=" ../src/main/kotlin/com/budilov/Properties.kt

echo "-Try out the following commands: -"

echo "Upload a picture"
echo "aws s3 cp new-york.jpg s3://${BUCKET_NAME}/usercontent/${COGNITO_POOL_ID}/"
echo
echo "Remove the picture"
echo "aws s3 rm s3://${BUCKET_NAME}/usercontent/${COGNITO_POOL_ID}/new-york.jpg"
echo
echo "Sample search command (that's after you login and upload a picture using your real Cognito Id). You'll need your JWT_TOKEN_ID as well"
echo "curl -X POST -H \"Authorization: ${JWT_ID_TOKEN}\" -H \"search-key: building\" -H \"Cache-Control: no-cache\" \"${API_GATEWAY_URL}/picture/search\""
echo
echo