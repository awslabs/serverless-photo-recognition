Serverless Photo Recognition
===================================================

### What is it?
A collection of 3 lambda functions that are invoked by Amazon S3, Amazon API Gateway, and directly (RESTful calls) 
to analyze uploaded images in S3 and save picture labels to ElasticSearch and search them

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
We need to setup cognito before we can do anything else. Follow the instructions on [this github repo](https://github.com/awslabs/aws-cognito-angular2-quickstart) to get everything setup. 

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

```aws s3 cp profile.JPG s3://<YOUR_BUCKET>/usercontent/<YOUR_COGNITO_ID>/```

Let's see what the logs tell us (the rekognition-add-pic Lambda function should have kicked off and you should 
see a log entry with the labels ):

```awslogs get /aws/lambda/rekognition-add-pic ALL -s1h | grep <picturename>```


