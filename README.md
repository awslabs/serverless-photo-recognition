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
The following command will setup all of the needed resources to get you going:

```./setup/setupEnvironment.sh```

It will also create a deletion script under the tmp directory

At the end of the script, you'll see 3 commands that you can run to test out your configuration. The ```curl``` command
requires you to follow the steps in the "Amazon Cognito" section below (to get the JWT token and your Cognito ID). You'll need
the latter to add an image the former to search your images. 

#### Amazon Cognito
You need to have the following Amazon Cognito parameters in order to test out this setup: 

* JWT ID Token
* Cognito Pool Id
* User Pool Id

Follow the instructions on [this github repo](https://github.com/awslabs/aws-cognito-angular2-quickstart) to
setup your own, fully-functioning, cognito-based website. 

Once you set it up, run ```npm start``` and go to the following url ```http://localhost:4200/```. Register and login, 
and you will see the following screen:
![Cognito Screen](/setup/img/cognito-screen.png?raw=true)

Write down the value of the cognito ID -- you will need it later on when testing your setup (the <YOUR_COGNITO_ID> value). 

Click on the JWT Tokens tab on the left, then "Id Token" tab and copy the token value. You'll need it
when running the curl command to search for images (the <JWT_ID_TOKEN> value). 

You'll need to update the com.budilov.Properties.kt object with the newly-created values, otherwise you'll get 
authentication errors. 


### Let's test it (use the script-provided commands for initial testing purposes)

_Upload a picture to the S3 bucket_

```aws s3 cp <IMAGE> s3://<YOUR_BUCKET>/usercontent/<YOUR_COGNITO_ID>/```

Let's see what the logs tell us (the rekognition-add-pic Lambda function should have kicked off and you should 
see a log entry with the labels )

```awslogs get /aws/lambda/rekognition-add-pic ALL -s1h```

You should see something similar to 

```Saving picture: PictureItem(id=1225251335, s3BucketUrl=my-pics.s3-website-us-east-1.amazonaws.com/usercontent/us-east-1:xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx/DSC09211.JPG, labels=[Bbq, Food, Bowl, Dish, Meal, Plate], signedUrl=null)```

_Now let's search using one of the above labels_

```curl -X POST -H "Authorization: <JWT_ID_TOKEN>" -H "search-key: bbq" -H "Cache-Control: no-cache" "<SEARCH_URL>/prd/picture/search"```

You will get the following json as the result:

```
[
  {
    "id": "123412341234",
    "s3BucketUrl": "my-pics.s3-website-us-east-1.amazonaws.com/usercontent/us-east-1:xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx/DSC09211.JPG",
    "labels": [
      "Bbq",
      "Food",
      "Bowl",
      "Dish",
      "Meal",
      "Plate"
    ],
    "signedUrl": "https://my-pics.s3.amazonaws.com/usercontent/us-east-1%xxxxxx-xxxx-xxxx-98d4-xxxxxxxxxxx/DSC09211.JPG?x-amz-security-token=FQoDYXdzELb%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaDK1aumxkOQQiNlDwEiLoAWcJV00GoCsNQTbapygMvvtv0%2BGfjrzTT%2B5sPGr4UPrYXK6Y8cMi9CscswfQhfN3kRJpjdRaFl9eTsnSHrVGdX1C8DvQsKF7vxb52e4soW%2FkmIjdnB6LR1XD7Iv6sRVX0Eq%2BVh8uZUL0TVBhw73bDUMkJodjYsmolHT9g2ZlTwA1Itj9IvZm2OrofAuF%2BG1Lsc9tWidFlXG5ZjbPw8Qb37%2Fn%2Bo9J6m%2BsknwpWCUWwoNbU5MtSSB5hbe7qDp98Z3l%2FNjbFQUs4CLqXcx9nrm%2FXcy%2B2qaWwbcHp1dVVDkTwyEdTxByQLx2xfooqrrhwwU%3D&AWSAccessKeyId=ASIAIUAHRYGHP5P7D4KA&Expires=1484286784&Signature=ESsdWSpxLplh8A%2BlzeyA47BGWLM%3D"
  }
]
```

You should notice that the 'signedUrl' is a temporary signed url that S3 generated in order for you to access this particular
object. Every time the query runs a signedUrl is generated for each of the resulting pictures. 


_Let's delete the picture to test the delete functionality_

```aws s3 rm s3://<YOUR_BUCKET>/usercontent/<YOUR_COGNITO_ID>/<IMAGE>```

