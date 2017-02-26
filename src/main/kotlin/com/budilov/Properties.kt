package com.budilov

/**
 * Created by Vladimir Budilov
 *
 * Externalizing of app properties. Will be handy when writing unit tests and de-coupling
 * the storage of properties
 */

object Properties {
    val _REGION = "REGION_REPLACE_ME"
    val _ACCOUNT_NUMBER = "ACCOUNT_REPLACE_ME"
    val _BUCKET_NAME = "BUCKET_REPLACE_ME"
    val _BUCKET_URL = "." + _BUCKET_NAME + "-" + _REGION + ".amazonaws.com"
    val _ES_SERVICE_URL = "https://ES_SERVICE_URL_REPLACE_ME"
    val _REKOGNITION_URL = "https://rekognition." + _REGION + ".amazonaws.com"
    val _REKOGNITION_CONFIDENCE_THRESHOLD = 60
    val _COGNITO_POOL_ID = "COGNITO_POOL_ID_REPLACE_ME"
    val _USER_POOL_ID = "USER_POOL_ID_REPLACE_ME"
    val _COGNITO_POOL_ID_IDP_NAME = "cognito-idp." + _REGION + ".amazonaws.com/" + _USER_POOL_ID
    val _S3_SIGNED_URL_DURATION = 1
}

