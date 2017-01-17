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
There are multiple AWS services involved here. Follow the below instructions for each one of them 

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
trigger the _rekognition-add-pic_ Lambda function on a POST and _rekognition-del-pic_ on a DELETE


#### Amazon API Gateway
Setup your API Gateway Proxy with Lambda as your Integration endpoint. See instructions below:
[API Gateway Proxy Setup](http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-set-up-simple-proxy.html)

You can use the swagger definitions included under ```setup/apigateway-swagger.json```, but make sure to modify the 
Amazon Cognito configurations before importing the swagger definition -- it'll fail otherwise. 

API Gateway will proxy the requests with the following data being available to you 
(POJO defined in com.budilov.pojo.ApigatewayRequest.kt):
```

{
    "path":"/picture/search",
    "headers":{
    "Accept":"*/*",
    "Accept-Encoding":"gzip, deflate, br",
    "Accept-Language":"en-US,en;q\u003d0.8,ru;q\u003d0.6",
    "Authorization":"aaaaa.bbbbb.cccccc",
    "Cache-Control":"no-cache",
    "CloudFront-Forwarded-Proto":"https",
    "CloudFront-Is-Desktop-Viewer":"true",
    "CloudFront-Is-Mobile-Viewer":"false",
    "CloudFront-Is-SmartTV-Viewer":"false",
    "CloudFront-Is-Tablet-Viewer":"false",
    "CloudFront-Viewer-Country":"US",
    "Content-Type":"text/plain;charset\u003dUTF-8",
    "DNT":"1",
    "Host":"e9djdv2xjb.execute-api.us-east-1.amazonaws.com",
    "Origin":"chrome-extension://fhbjgbiflinjbdggehcddcbncdddomop",
    "Postman-Token":"00f89100-c230-2a1b-36b3-d854b4bb432f",
    "search-key":"glasses",
    "User-Agent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36",
    "Via":"1.1 829eee129e6b5002d6c1a37f04888da1.cloudfront.net (CloudFront)",
    "X-Amz-Cf-Id":"VxjWNrjlTek5VOJ2tMoPzYJXXZ9wIsddjDxMT-ncCsxsU7AoRiXYLA\u003d\u003d",
    "X-Forwarded-For":"71.162.161.103, 54.240.159.56",
    "X-Forwarded-Port":"443",
    "X-Forwarded-Proto":"https"
},
    "requestContext":{
    "accountId":"540403165297",
    "resourceId":"ywrcne",
    "stage":"prd",
    "requestId":"2f5b082a-d57a-11e6-9502-5b8a76e3fba2",
    "identity":{
    "sourceIp":"71.162.161.103",
    "userAgent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36"
},
    "authorizer":{
    "claims":{
    "sub":"aaaaaaa-bbbbb-ccccc-ddddd-eeeeeeeeeeee",
    "aud":"asdfasdfasdfasdf",
    "email_verified":"true",
    "token_use":"id",
    "auth_time":"1483859554",
    "iss":"https://cognito-idp.us-east-1.amazonaws.com/us-east-1_AAAAAAAAA",
    "nickname":"Vladimir",
    "cognito:username":"vladimir.budilov@myemaildomain.com",
    "exp":"Sun Jan 08 08:12:34 UTC 2017",
    "iat":"Sun Jan 08 07:12:34 UTC 2017",
    "email":"vladimir.budilov@myemaildomain.com"
}
},
    "resourcePath":"/picture/search",
    "httpMethod":"POST",
    "apiId":"asdfasdfasdfasdf"
},
    "resource":"/picture/search",
    "httpMethod":"POST"
}

```
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

```awslogs get /aws/lambda/rekognition-add-pic ALL -s1h```

You should see something similar to 

```Saving picture: PictureItem(id=1225251335, s3BucketUrl=my-pics.s3-website-us-east-1.amazonaws.com/usercontent/us-east-1:xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx/DSC09211.JPG, labels=[Bbq, Food, Bowl, Dish, Meal, Plate], signedUrl=null)```

Now let's search using one of the above labels:

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


Let's delete the picture to test the delete functionality:

```aws s3 rm s3://<YOUR_BUCKET>/usercontent/<YOUR_COGNITO_ID>/<IMAGE>```

