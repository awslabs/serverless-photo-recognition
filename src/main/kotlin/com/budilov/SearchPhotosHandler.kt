package com.budilov

import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import com.budilov.db.ESPictureService
import com.budilov.pojo.ApigatewayRequest
import com.budilov.pojo.PictureItem
import com.budilov.s3.S3Service
import com.google.gson.Gson
import java.util.*

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
            //todo: figure out how to get this value programmatically based on the jwt claims
            val userId = request.headers?.get(userIdName) ?: ""

            val pictureList: List<PictureItem> = esService.search(userId, searchString)
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
}