#!/usr/bin/env bash

ROOT_NAME=$(date +%Y%m%d%H%M%S)
echo "Using the following 'root name' for your resources, such as S3 bucket: " ${ROOT_NAME}

BUCKET_NAME=rekognition-${ROOT_NAME}
REGION=us-east-1
ES_DOMAIN_NAME=rekognition # if you change this value, you'll need to change the values in the elasticsearch_service_policy.json file
EXTERNAL_IP_ADDRESS=$(curl ipinfo.io/ip)
ACCOUNT_NUMBER=$(aws ec2 describe-security-groups --group-names 'Default' --query 'SecurityGroups[0].OwnerId' --output text)
COGNITO_POOL_NAME_REPLACE_ME=${ROOT_NAME}rek

# Lambda
JAR_LOCATION=../build/libs/rekognition-rest-1.0-SNAPSHOT.jar
FUNCTION_REK_SEARCH=rekognition-search-picture
FUNCTION_REK_ADD=rekognition-add-picture
FUNCTION_REK_DEL=rekognition-del-picture
FUNCTION_REK_SEARCH_HANDLER=com.budilov.SearchPhotosHandler
FUNCTION_REK_ADD_HANDLER=com.budilov.AddPhotoLambda
FUNCTION_REK_DEL_HANDLER=com.budilov.RemovePhotoLambda

# IAM
ROLE_NAME=s3-to-es

# ES
ES_DOMAIN_NAME=rekognition${ROOT_NAME}

# Methods
createLambdaFunction() {
   if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
     echo "No parameters were passed"
     exit -1
   fi

    aws lambda create-function --region $1 \
        --function-name $2 \
        --zip-file fileb://$3 \
        --role arn:aws:iam::${ACCOUNT_NUMBER}:role/s3-to-es \
        --handler $4 \
        --runtime java8 \
        --memory-size 192 \
        --timeout 20
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
./createResources.sh ${COGNITO_POOL_NAME_REPLACE_ME} ${ACCOUNT_NUMBER} ${REGION}
USER_POOL_ID=$(cat /tmp/userPoolId)
COGNITO_POOL_ID=$(cat /tmp/identityPoolId)
echo "Cognito User Pool Id: " ${USER_POOL_ID}
echo "Cognito Identity Id: " + ${COGNITO_POOL_ID}
cd ..

POOL_ARN_REPLACE_ME=arn:aws:cognito-idp:${REGION}:${ACCOUNT_NUMBER}:userpool/${USER_POOL_ID}

# Create IAM roles
aws iam create-role --role-name s3-to-es --assume-role-policy-document file://s3-to-es-role-trust-relationship.json
aws iam attach-role-policy --role-name s3-to-es --policy-arn arn:aws:iam::aws:policy/AmazonESFullAccess
aws iam attach-role-policy --role-name s3-to-es --policy-arn arn:aws:iam::aws:policy/AmazonRekognitionFullAccess
aws iam attach-role-policy --role-name s3-to-es --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Create the photos bucket
aws s3 mb s3://$BUCKET_NAME/ --region $REGION

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

# Import your API Gateway Swagger template. This command can run after the Cognito User Pool is created
## First substitute values in the swagger file: COGNITO_POOL_NAME_REPLACE_ME,
## POOL_ARN_REPLACE_ME, REKOGNITION_ADD_FUNCTION, REKOGNITION_DELETE_FUNCTION, REKOGNITION_SEARCH_FUNCTION
echo "Preparing the swagger template. REGION: " ${REGION} " COGNITO_POOL_NAME: " ${COGNITO_POOL_NAME_REPLACE_ME} " POOL_ARN_REPLACE_ME: " ${POOL_ARN_REPLACE_ME} " REKOGNITION_SEARCH_FUNCTION_ARN: " ${REKOGNITION_SEARCH_FUNCTION_ARN}
cat apigateway-swagger.json |
    sed 's#REGION_REPLACE_ME#'${REGION}'#g' |
    sed 's#COGNITO_POOL_NAME_REPLACE_ME#'${COGNITO_POOL_NAME_REPLACE_ME}'#g' |
    sed 's#POOL_ARN_REPLACE_ME#'${POOL_ARN_REPLACE_ME}'#g' |
    sed 's#REKOGNITION_SEARCH_FUNCTION_ARN_REPLACE_ME#'${REKOGNITION_SEARCH_FUNCTION_ARN}'#g' > /tmp/apigateway-swagger.json

echo "Importing the swagger template"
aws apigateway import-rest-api --body 'file:///tmp/apigateway-swagger.json' --region ${REGION} > /tmp/apigateway-import-api
GATEWAY_ID=$(cat /tmp/apigateway-import-api | grep id | awk '{print $2}' | xargs |sed -e 's/^"//'  -e 's/"$//' -e 's/,$//')

## Deploy to 'prd' stage
echo "Deploying the gateway with id of " ${GATEWAY_ID} " to prd"
aws apigateway create-deployment --rest-api-id ${GATEWAY_ID} --stage-name prod

# Setup Elasticsearch
aws es create-elasticsearch-domain --domain-name ${ES_DOMAIN_NAME} --elasticsearch-version 5.1 --elasticsearch-cluster-config InstanceType=t2.small.elasticsearch,InstanceCount=1 --ebs-options EBSEnabled=true,VolumeType=standard,VolumeSize=10
cat elasticsearch_service_policy.json |
    sed 's#ACCOUNT_NAME_REPLACE_ME#'${ACCOUNT_NUMBER}'#g' |
    sed 's#REGION_REPLACE_ME#'${REGION}'#g' |
    sed 's#ROLE_NAME_REPLACE_ME#'${ROLE_NAME}'#g' |
    sed 's#ES_DOMAIN_NAME_REPLACE_ME#'${ES_DOMAIN_NAME}'#g' |
    sed 's#EXTERNAL_IP_ADDRESS_REPLACE_ME#'${EXTERNAL_IP_ADDRESS}'#g' > /tmp/elasticsearch_service_policy.json
aws es update-elasticsearch-domain-config --domain-name ${ES_DOMAIN_NAME} --access-policies file:///tmp/elasticsearch_service_policy.json

ES_ENDPOINT=$(aws es describe-elasticsearch-domain --domain-name ${ES_DOMAIN_NAME} --query "DomainStatus.Endpoint" --output text)

# Replace all of the property values in Properties.kt
cat ../src/main/kotlin/com/budilov/Properties.kt |
    sed 's#REGION_REPLACE_ME#'${REGION}'#g' |
    sed 's#ACCOUNT_REPLACE_ME#'${ACCOUNT_NUMBER}'#g' |
    sed 's#COGNITO_POOL_ID_REPLACE_ME#'${COGNITO_POOL_ID}'#g' |
    sed 's#USER_POOL_ID_REPLACE_ME#'${USER_POOL_ID}'#g' |
    sed 's#ES_SERVICE_URL_REPLACE_ME#'${ES_ENDPOINT}'#g' |
    sed 's#BUCKET_REPLACE_ME#'${BUCKET_NAME}'#g' > ../src/main/kotlin/com/budilov/Properties.kt

# Build the code again and update all of the lambda functions
cd ..
./gradlew build
cd setup
updateFunction ${REGION} ${FUNCTION_REK_ADD} ${JAR_LOCATION}
updateFunction ${REGION} ${FUNCTION_REK_DEL} ${JAR_LOCATION}
updateFunction ${REGION} ${FUNCTION_REK_SEARCH} ${JAR_LOCATION}

echo "You're done"