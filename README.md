Serverless Photo Recognition
===================================================
### What is it?
A collection of 3 lambda functions that are invoked by Amazon S3, Amazon API Gateway, and directly (RESTful calls) 
to analyze uploaded images in S3 with Amazon Rekognition and save picture metadata to ElasticSearch

## Author: Vladimir Budilov
* [LinkedIn](https://www.linkedin.com/in/vbudilov/)
* [Medium](https://medium.com/@budilov)

### The Architecture

#### Adding an image
![Adding an image](/setup/img/ServerlessPhotoRecognition_Add_Image.png?raw=true)

#### Removing an image
![Remove an image](/setup/img/ServerlessPhotoRecognition_Remove_Image.png?raw=true)

#### Searching images
![Search images](/setup/img/ServerlessPhotoRecognition_Search_Image.png?raw=true)

### Tech Stack
#### Required Tools
* [aws cli](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
* [awslogs utility](https://github.com/jorgebastida/awslogs)

#### AWS Services Involved In This Architecture
* [Amazon Rekognition](https://aws.amazon.com/rekognition/)
* [Amazon Cognito](https://aws.amazon.com/cognito/)
* [AWS Lambda](https://aws.amazon.com/lambda/)
* [Amazon API Gateway](https://aws.amazon.com/api-gateway/)
* [Amazon S3](https://aws.amazon.com/s3/)
* [Amazon Elasticsearch](https://aws.amazon.com/elasticsearch-service/)

### AWS Setup
Before we start, let’s make sure that your working environment is setup to run the script. Here's what you'll need:

* An AWS Account with a default VPC
* Java 8
* The latest AWS CLI (Tested with aws-cli/1.11.29 Python/2.7.12)
* Linux or Mac OS to run the setup script (the setup script won't work on Windows)

The following command will setup all of the needed resources, as well as print out the sample command that you can run
to test your configuration:
```
# Clone it from github
git clone --depth 1 https://github.com/awslabs/serverless-photo-recognition.git
```
```
# Run the installation script
cd serverless-photo-recognition/setup
./setupEnvironment.sh
```
Running the installation script will modify the ```/src/main/kotlin/com/budilov/Properties.kt``` file with the newly-generated values. If you need to rerun the script, just revert the changes (otherwise the script will fail). 

It will also create a deletion script under the ```tmp``` directory

At the end of the script, you'll see 3 commands (customized with your environment variables) that you can run to test out your configuration. Run the commands and see the functionality in action (copying and running the below commands will fail...use the ones that the script has generated):

```
-> Upload a picture
--------------------
aws s3 cp new-york.jpg s3://rekognition-20170307160632/usercontent/us-east-1:c61126b8-7f7b-48e8-8534-4c3a21dfef4e/

-> Sample search command
You might need to pipe the output to 'native2ascii -encoding UTF-8 -reverse' if you
want to copy and paste the signed url in the browser since curl encodes url output
-------------------------
curl -X POST -H "Authorization: $(aws cognito-idp admin-initiate-auth  --user-pool-id us-east-1_AEzYFK4mc --client-id 734810igh3bfdj4n33tfm9o08s --cli-input-json file:///tmp/authflow.json --query AuthenticationResult.IdToken --output text)" -H "search-key: building" -H "Cache-Control: no-cache" "https://57zt8cwa6j.execute-api.us-east-1.amazonaws.com/prod/picture/search/"

-> Remove the picture
----------------------
aws s3 rm s3://rekognition-20170307160632/usercontent/us-east-1:c61126b8-7f7b-48e8-8534-4c3a21dfef4e/new-york.jpg
```

