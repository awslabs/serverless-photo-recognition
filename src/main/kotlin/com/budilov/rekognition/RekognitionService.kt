package com.budilov.rekognition


import com.amazonaws.auth.EnvironmentVariableCredentialsProvider
import com.amazonaws.services.rekognition.AmazonRekognitionClient
import com.amazonaws.services.rekognition.model.DetectLabelsRequest
import com.amazonaws.services.rekognition.model.Image
import com.amazonaws.services.rekognition.model.S3Object
import com.budilov.Properties


/**
 * Created by Vladimir Budilov on 11/18/16.
 *
 * The recognition service implementation
 */

class RekognitionService {

    val rekognitionClient = AmazonRekognitionClient(EnvironmentVariableCredentialsProvider())

    /**
     * Returns a list of Rekognition labels for a particular picture in the specified
     * bucket
     */
    fun getLabels(bucketName: String, objectName: String): List<String> {
        val s3Object = S3Object().withBucket(bucketName).withName(objectName)

        val req = DetectLabelsRequest()
        req.image = Image().withS3Object(s3Object)

        rekognitionClient.setEndpoint(Properties._REKOGNITION_URL)
        rekognitionClient.signerRegionOverride = Properties._REGION

        val res = rekognitionClient.detectLabels(req)

        val labels: MutableList<String> = arrayListOf()
        // Make sure that the confidence level of the label is above our threshold...if so, add it to the map
        res?.labels?.filter { it.confidence >= Properties._REKOGNITION_CONFIDENCE_THRESHOLD }
                ?.mapTo(labels) { it.name }

        return labels
    }
}