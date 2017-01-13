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
        println("bucketName: " + bucketName + " object: " + objectName)

        val s3Object = S3Object().withBucket(bucketName).withName(objectName)

        val req = DetectLabelsRequest()
        req.image = Image().withS3Object(s3Object)

        rekognitionClient.setEndpoint(Properties.getRekognitionUrl())
        rekognitionClient.setSignerRegionOverride(Properties.getRegion())

        val res = try {
            rekognitionClient.detectLabels(req)
        } catch (e: Exception) {
            println("Exception: " + e.toString())
            null
        }

        val labels: MutableList<String> = arrayListOf()
        // Make sure that the confidence level of the labe is above our threshold...if so, add it to the map
        res?.labels?.filter { it.confidence > Properties.getRekognitionConfidenceThreshold() }
                ?.mapTo(labels) { it.name }

        return labels
    }
}