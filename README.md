Serverless Photo Recognition
===================================================

### What is it?
A collection of 3 lambda functions that are invoked by Amazon S3, Amazon API Gateway, and directly (RESTful calls) 
to analyze uploaded images in S3 with Amazon Rekognition and save picture metadata to ElasticSearch

### The Architecture

####Adding an image
![Adding an image](/setup/img/ServerlessPhotoRecognition_Add_Image.png?raw=true)

####Removing an image
![Remove an image](/setup/img/ServerlessPhotoRecognition_Remove_Image.png?raw=true)

####Searching images
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
The following command will setup all of the needed resources, as well as print out the sample command that you can run
to test your configuration:

```
setup/setupEnvironment.sh
```

It will also create a deletion script under the ```tmp``` directory

At the end of the script, you'll see 3 commands that you can run to test out your configuration. Run the command and see the functionality in action:

```
   Upload a picture
   aws s3 cp new-york.jpg s3://rekognition-111111111111/usercontent/us-east-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx/
   
   Remove the picture
   aws s3 rm s3://rekognition-111111111111/usercontent/us-east-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx/new-york.jpg
   
   Sample search command
   curl -X POST -H "Authorization: some-code-generated-here" -H "search-key: building" -H "Cache-Control: no-cache" "https://uniqueprefix.execute-api.us-east-1.amazonaws.com/prod/picture/search/"
   ```

