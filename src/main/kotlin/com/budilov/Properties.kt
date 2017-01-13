package com.budilov

/**
 * Created by Vladimir Budilov
 *
 * Externalizing of app properties. Will be handy when writing unit tests and de-coupling
 * the storage of properties
 */

object Properties {
     val _REGION = "us-east-1"
    private val _ACCOUNT_NUMBER = "540403165297"
    private val _BUCKET_NAME = "rekognition-pics"
    private val _BUCKET_URL = "." + _BUCKET_NAME + "-" + _REGION + ".amazonaws.com"
    private val _ES_SERVICE_URL = "https://search-rekognition-6pce3dkelwl47wm3urifjfvk6u." + Properties._REGION + ".es.amazonaws.com"
    private val _REKOGNITION_URL = "https://rekognition." + Properties.getRegion() + ".amazonaws.com"
    private val _REKOGNITION_CONFIDENCE_THRESHOLD = 60
    private val _COGNITO_POOL_ID = "us-east-1:fbe0340f-9ffc-4449-a935-bb6a6661fd53"
    private val _USER_POOL_ID = "us-east-1_PGSbCVZ7S"
    private val _COGNITO_POOL_ID_IDP_NAME = "cognito-idp." + _REGION + ".amazonaws.com/" + _USER_POOL_ID

    fun getBucketName(): String {
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

    fun getCognitoPoolIdpName(): String {
        return _COGNITO_POOL_ID_IDP_NAME
    }

    fun getCognitoPoolId(): String {
        return _COGNITO_POOL_ID
    }

    fun getAccountNumber(): String {
        return _ACCOUNT_NUMBER
    }
}

