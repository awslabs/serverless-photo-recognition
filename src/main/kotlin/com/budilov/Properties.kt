package com.budilov

/**
 * Created by Vladimir Budilov
 *
 * Externalizing of app properties. Will be handy when writing unit tests and de-coupling
 * the storage of properties
 */

object Properties {
    val _REGION = "us-east-1"
    val _ACCOUNT_NUMBER = "540403165297"
    val _BUCKET_NAME = "rekognition-pics"
    val _BUCKET_URL = "." + _BUCKET_NAME + "-" + _REGION + ".amazonaws.com"
    val _ES_SERVICE_URL = "https://search-rekognition-6pce3dkelwl47wm3urifjfvk6u." + Properties._REGION + ".es.amazonaws.com"
    val _REKOGNITION_URL = "https://rekognition." + Properties._REGION + ".amazonaws.com"
    val _REKOGNITION_CONFIDENCE_THRESHOLD = 60
    val _COGNITO_POOL_ID = "us-east-1:fbe0340f-9ffc-4449-a935-bb6a6661fd53"
    val _USER_POOL_ID = "us-east-1_PGSbCVZ7S"
    val _COGNITO_POOL_ID_IDP_NAME = "cognito-idp." + _REGION + ".amazonaws.com/" + _USER_POOL_ID
    val _S3_SIGNED_URL_DURATION = 1

}

