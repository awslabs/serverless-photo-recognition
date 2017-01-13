package com.budilov.pojo

import io.searchbox.annotations.JestId

/**
 * Created by Vladimir Budilov
 *
 */
data class PictureItem(@JestId val id: String, val s3BucketUrl: String, val labels: List<String>?, var signedUrl: String?)
