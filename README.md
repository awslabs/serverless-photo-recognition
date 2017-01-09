Serverless Photo Recognition (WIP)
===================================================

## What is it?
A collection of 3 lambda functions that are invoked by Amazon S3, Amazon API Gateway, and directly (RESTful calls) 
to analyze uploaded images in S3 and save picture labels to ElasticSearch and search them

## Tech Stack
### Required Tools
* [aws cli](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
* [awslogs utility](https://github.com/jorgebastida/awslogs)

### AWS Services
* [AWS Lambda](https://aws.amazon.com/lambda/)
* [Amazon API Gateway](https://aws.amazon.com/api-gateway/)
* [Amazon Rekognition](https://aws.amazon.com/rekognition/)
* [Amazon S3](https://aws.amazon.com/s3/)

## AWS Setup

### Lambda
For convenience, all 3 AWS Lambda functions are packaged in this project, but you might want to separate them 
into different projects due minimize the size of each Lambda function

### S3

### API Gateway
[API Gateway Proxy Setup](http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-set-up-simple-proxy.html)

### Rekognition


## Getting the code

## Necessary changes

