Serverless Photo Recognition
===================================================

### What is it?
A collection of 3 lambda functions that are invoked by Amazon S3, Amazon API Gateway, and directly (RESTful calls) 
to analyze uploaded images in S3 and save picture labels to ElasticSearch and search them

### The Architecture
![ServerlessPhotoRecognitionArchitecture](/setup/img/ServerlessPhotoRecognitionArchitecture.png?raw=true)

### Tech Stack
#### Required Tools
* [aws cli](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
* [awslogs utility](https://github.com/jorgebastida/awslogs)

#### AWS Services
* [AWS Lambda](https://aws.amazon.com/lambda/)
* [Amazon API Gateway](https://aws.amazon.com/api-gateway/)
* [Amazon Rekognition](https://aws.amazon.com/rekognition/)
* [Amazon S3](https://aws.amazon.com/s3/)

### AWS Setup
There are multiple AWS services involved here. Follow the below instructions for each one of them 

#### Amazon Cognito
You need to have the following Amazon Cognito parameters in order to test out this setup: 

* JWT ID Token
* Cognito Pool Id
* User Pool Id

There are two ways of getting them. The first one is for you to go to (this demo site)[http://cognito.budilov.com], 
register & login, and then follow the instructions below, or you can setup the demo site yourself by creating 
all of the required services (this will force you to change the content of the Properties.kt object with your own, 
updated values). Follow the instructions on [this github repo](https://github.com/awslabs/aws-cognito-angular2-quickstart) if you choose the latter. 

Once you set it up, run ```npm start``` and go to the following url ```http://localhost:4200/``` (or just go (here)[http://cognito.budilov.com]). Register and login, 
and you will see the following screen once you login:
![Cognito Screen](/setup/img/cognito-screen.png?raw=true)

Write down the value of cognito ID -- you will need it later on when testing your setup (the <YOUR_COGNITO_ID> value). 

Click on the JWT Tokens tab on the left, then "Id Token" tab and copy the token value. You'll need it
when running the curl command to search for images (the <JWT_ID_TOKEN> value). 

Note: As noted, if you went the route of setting up your own Amazon Cognito service, you'll need to 
update the com.budilov.Properties.kt object with the values, otherwise you'll get authentication errors. 

#### AWS Lambda
For convenience, all 3 AWS Lambda functions are packaged in this project (later on you might want to separate them 
into different projects to minimize the size of each Lambda function)

Build the code with ```./gradlew jar```  and use the generated artifact under 
```build/libs/rekognition-rest-1.0-SNAPSHOT.jar``` to create the following three Lambda functions

* rekognition-api
    * use setup/lambda_to_elasticsearch_policy.json as the role's policy
* rekognition-add-pic
    * use setup/amazon_rekognition_full_access_policy.json
* rekognition-del-pic
    * use setup/amazon_rekognition_full_access_policy.json

#### Amazon S3
Setup an S3 bucket where you will upload pictures. You need to create an event that will
trigger the rekognition-add-pic Lambda function on a POST and rekognition-del-pic on a DELETE


#### Amazon API Gateway
Setup your API Gateway. See instructions below:
[API Gateway Proxy Setup](http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-set-up-simple-proxy.html)

Use the swagger definitions included under ```setup/api-gateway-swagger.json```

#### Amazon Rekognition
You don't need to do anything specific to start using Amazon Rekognition. 

#### Amazon ElasticSearch 
You'll need to create an ElasticSearch cluster (either on your own or using the Amazon Elasticsearch service). Use the
```setup/elasticsearch_service_policy.json``` access policy as a guide (modify the account number, role name, and IP address)

The provided sample policy is required to allow only the Lambda functions that are running with a specific role to 
have access to the Elasticsearch cluster

### Let's test it
Upload a picture to the S3 bucket:

```aws s3 cp <IMAGE> s3://<YOUR_BUCKET>/usercontent/<YOUR_COGNITO_ID>/```

Let's see what the logs tell us (the rekognition-add-pic Lambda function should have kicked off and you should 
see a log entry with the labels ):

```awslogs get /aws/lambda/rekognition-add-pic ALL -s1h | grep <picturename>```

Now let's search:

```curl -X POST -H "Authorization: <JWT_ID_TOKEN>" -H "search-key: glasses" -H "Cache-Control: no-cache" "https://e9djdv2xjb.execute-api.us-east-1.amazonaws.com/prd/picture/search"```