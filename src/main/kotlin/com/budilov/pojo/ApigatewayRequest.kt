package com.budilov.pojo

/**
 * Created by Vladimir Budilov
 *
 * This is the POJO for API Gateway Proxy with Cognito Auth implementation
 *
 *
 */
//
//{
//    "path":"/picture/search",
//    "headers":{
//    "Accept":"*/*",
//    "Accept-Encoding":"gzip, deflate, br",
//    "Accept-Language":"en-US,en;q\u003d0.8,ru;q\u003d0.6",
//    "Authorization":"aaaaa.bbbbb.cccccc",
//    "Cache-Control":"no-cache",
//    "CloudFront-Forwarded-Proto":"https",
//    "CloudFront-Is-Desktop-Viewer":"true",
//    "CloudFront-Is-Mobile-Viewer":"false",
//    "CloudFront-Is-SmartTV-Viewer":"false",
//    "CloudFront-Is-Tablet-Viewer":"false",
//    "CloudFront-Viewer-Country":"US",
//    "Content-Type":"text/plain;charset\u003dUTF-8",
//    "DNT":"1",
//    "Host":"e9djdv2xjb.execute-api.us-east-1.amazonaws.com",
//    "Origin":"chrome-extension://fhbjgbiflinjbdggehcddcbncdddomop",
//    "Postman-Token":"00f89100-c230-2a1b-36b3-d854b4bb432f",
//    "search-key":"glasses",
//    "User-Agent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36",
//    "Via":"1.1 829eee129e6b5002d6c1a37f04888da1.cloudfront.net (CloudFront)",
//    "X-Amz-Cf-Id":"VxjWNrjlTek5VOJ2tMoPzYJXXZ9wIsddjDxMT-ncCsxsU7AoRiXYLA\u003d\u003d",
//    "X-Forwarded-For":"71.162.161.103, 54.240.159.56",
//    "X-Forwarded-Port":"443",
//    "X-Forwarded-Proto":"https"
//},
//    "requestContext":{
//    "accountId":"540403165297",
//    "resourceId":"ywrcne",
//    "stage":"prd",
//    "requestId":"2f5b082a-d57a-11e6-9502-5b8a76e3fba2",
//    "identity":{
//    "sourceIp":"71.162.161.103",
//    "userAgent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36"
//},
//    "authorizer":{
//    "claims":{
//    "sub":"aaaaaaa-bbbbb-ccccc-ddddd-eeeeeeeeeeee",
//    "aud":"asdfasdfasdfasdf",
//    "email_verified":"true",
//    "token_use":"id",
//    "auth_time":"1483859554",
//    "iss":"https://cognito-idp.us-east-1.amazonaws.com/us-east-1_AAAAAAAAA",
//    "nickname":"Vladimir",
//    "cognito:username":"vladimir.budilov@myemaildomain.com",
//    "exp":"Sun Jan 08 08:12:34 UTC 2017",
//    "iat":"Sun Jan 08 07:12:34 UTC 2017",
//    "email":"vladimir.budilov@myemaildomain.com"
//}
//},
//    "resourcePath":"/picture/search",
//    "httpMethod":"POST",
//    "apiId":"asdfasdfasdfasdf"
//},
//    "resource":"/picture/search",
//    "httpMethod":"POST"
//}
data class ApigatewayRequest(var input: Input? = null) {
    data class RequestContext(var accountId: String? = null,
                              var resourceId: String? = null,
                              var stage: String? = null,
                              var requestId: String? = null,
                              var identity: MutableMap<String, String>? = null,
                              var authorizer: Authorizer? = null,
                              var resourcePath: String? = null,
                              var httpMethod: String? = null,
                              var apiId: String? = null)

    data class Authorizer(var principalId: String? = null, var claims: MutableMap<String, String>? = null)

    data class Input(var path: String? = null,
                     var headers: MutableMap<String, String>? = null,
                     var pathParameters: MutableMap<String, String>? = null,
                     var requestContext: RequestContext? = null,
                     var resource: String? = null,
                     var httpMethod: String? = null,
                     var queryStringParameters: MutableMap<String, String>? = null,
                     var stageVariables: MutableMap<String, String>? = null
    )
}