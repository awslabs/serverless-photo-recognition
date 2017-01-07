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


    fun getLabels(bucketName: String, objectName: String): List<String> {
        println("bucketName: " + bucketName + " object: " + objectName)

        var labels: MutableList<String> = arrayListOf()

        val s3Object = S3Object().withBucket(bucketName).withName(objectName)

        val req = DetectLabelsRequest()
        req.image = Image().withS3Object(s3Object)

        val rekognitionClient = AmazonRekognitionClient(EnvironmentVariableCredentialsProvider())
        rekognitionClient.setEndpoint(Properties.getRekognitionUrl())
        rekognitionClient.setSignerRegionOverride(Properties.getRegion())

        val res = try {
            rekognitionClient.detectLabels(req)
        } catch (e: Exception) {
            println("Exception: " + e.toString())
            null
        }

        if (res != null)
            res.labels?.filter { it.confidence > Properties.getRekognitionConfidenceThreshold() }
                    ?.mapTo(labels) { it.name }

        return labels
    }
}