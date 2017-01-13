package com.budilov

import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import com.amazonaws.services.lambda.runtime.events.S3Event
import com.budilov.db.ESPictureService
import com.budilov.pojo.PictureItem
import java.net.URLDecoder


/**
 * Created by Vladimir Budilov
 *
 * This Lambda function is triggered by S3 whenever an object is deleted. It will gather
 * the needed information and remove the entry from ElasticSearch
 *
 */
class RemovePhotoLambda : RequestHandler<S3Event, String> {

    val esService = ESPictureService()

    /**
     * 1. Get the s3 bucket and object name in question
     * 2. Clean the object name
     * 3. Delete the bucket/object & labels from ElasticSearch
     */
    override fun handleRequest(s3event: S3Event, context: Context): String {
        val logger = context.logger
        val record = s3event.getRecords().get(0)

        val srcBucket = record.getS3().getBucket().name

        // Object key may have spaces or unicode non-ASCII characters.
        var srcKeyEncoded = record.s3.`object`.key
                .replace('+', ' ')

        logger?.log("Full object name: " + record.s3.`object`.toString())
        val srcKey = URLDecoder.decode(srcKeyEncoded, "UTF-8")
        logger?.log("bucket: " + srcBucket + " key: " + srcKey)

        val picture = PictureItem(srcKeyEncoded.hashCode().toString(), srcBucket + Properties.getBucketSuffix() + "/" + srcKey, null, null)
        logger?.log("Removing picture from ES: " + picture)

        // Getting the cognito id from the object name (it's a prefix)
        val cognitoId = srcKey.split("/")[1]
        logger?.log("Cognito ID: " + cognitoId)

        esService.delete(cognitoId, picture)

        return "Ok"

    }
}