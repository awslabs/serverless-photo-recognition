package com.budilov

/**
 * Created by Vladimir Budilov
 *
 * Externalizing of app properties. Will be handy when writing unit tests and de-coupling
 * the storage of properties
 */

object Properties {
    private val _REGION = "us-east-1"
    private val _BUCKET_NAME = "s3-website"
    private val _BUCKET_URL = "." + _BUCKET_NAME + "-" + _REGION + ".amazonaws.com"
    private val _ES_SERVICE_URL = "https://search-rekognition-6pce3dkelwl47wm3urifjfvk6u." + Properties._REGION + ".es.amazonaws.com"
    private val _REKOGNITION_URL = "https://rekognition." + Properties.getRegion() + ".amazonaws.com"
    private val _REKOGNITION_CONFIDENCE_THRESHOLD = 60

    fun getBucketName() :String {
        return _BUCKET_NAME
    }
    fun getESServiceUrl(): String {
        return _ES_SERVICE_URL
    }

    fun getRegion(): String {
        return _REGION
    }

    fun getBucketSuffix(): String {
        return _BUCKET_URL
    }

    fun getRekognitionUrl(): String {
        return _REKOGNITION_URL
    }

    fun getRekognitionConfidenceThreshold(): Int {
        return _REKOGNITION_CONFIDENCE_THRESHOLD
    }
}

