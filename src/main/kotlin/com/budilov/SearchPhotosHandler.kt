package com.budilov

import com.amazonaws.services.cognitoidentity.AmazonCognitoIdentityClient
import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import com.budilov.db.ESPictureService
import com.budilov.pojo.ApigatewayRequest
import com.budilov.pojo.PictureItem
import com.budilov.s3.S3Service
import com.google.gson.Gson
import java.util.*
import com.amazonaws.auth.AnonymousAWSCredentials
import com.amazonaws.services.cognitoidentity.AmazonCognitoIdentity
import com.amazonaws.services.cognitoidentity.model.GetIdResult
import com.amazonaws.services.cognitoidentity.model.GetIdRequest





/**
 * Created by Vladimir Budilov
 *
 * This Lambda function allows clients to search the ElasticSearch index for photos with specific tags.
 *
 * The API Gateway requests need to be signed: https://docs.aws.amazon.com/apigateway/api-reference/signing-requests/
 *
 *
 */

class SearchPhotosHandler : RequestHandler<ApigatewayRequest.Input, SearchPhotosHandler.SearchResponse> {
    val esService = ESPictureService()
    val searchKeyName = "search-key"
    val userIdName = "user-key"
    val identityClient: AmazonCognitoIdentity = AmazonCognitoIdentityClient(AnonymousAWSCredentials())

    data class SearchResponse(var statusCode: Int = 500,
                              var headers: MutableMap<String, String> = HashMap<String, String>(),
                              var body: String? = null)

    /**
     * 1. Get the request from API Gateway. Unmarshal (automatically) the request
     * 2. Get the
     */
    override fun handleRequest(request: ApigatewayRequest.Input?, context: Context?): SearchResponse? {
        val response = SearchResponse()
        val logger = context?.logger

        logger?.log("request payload: " + Gson().toJson(request))

        if (request == null || context == null) {
            logger?.log("request or context is null")
        } else {
            val searchString = request.headers?.get(searchKeyName) ?: ""
            val pictureList: List<PictureItem> = esService.search(getCognitoId(request.headers?.get("Authorization") ?: ""), searchString)
            logger?.log("Found pictures: " + pictureList)

            for (picture in pictureList) {
                println("object: " + picture.s3BucketUrl.substringAfter("/"))

                picture.signedUrl = S3Service.getSignedUrl(Properties.getBucketName(),
                        picture.s3BucketUrl.substringAfter("/")).toString()
            }
            response.statusCode = 200
            response.headers.put("Content-Type", "application/json")
            response.body = Gson().toJson(pictureList)
        }

        return response
    }

    /**
     * Retrieve the cognito id from the cognito service
     *
     * The result should be cached so as not to call the cognito service for every single request (although I'm not
     * caching it anywhere right now)
     */
    fun getCognitoId(authToken:String):String {
        println("getCognitoId: enter")

        val idRequest = GetIdRequest()
        idRequest.accountId = Properties.getAccountNumber()
        idRequest.identityPoolId = Properties.getCognitoPoolId()
        var providerTokens:Map<String, String> = mapOf(Pair(Properties.getCognitoPoolIdpName(), authToken))

        idRequest.setLogins(providerTokens);

        val idResp = identityClient.getId(idRequest)

        return idResp.identityId ?: ""
    }
}