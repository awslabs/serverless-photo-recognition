package com.budilov.pojo

/**
 * Created by Vladimir Budilov
 *
 * This is the POJO for API Gateway Proxy with Cognito Auth implementation
 *
 */

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