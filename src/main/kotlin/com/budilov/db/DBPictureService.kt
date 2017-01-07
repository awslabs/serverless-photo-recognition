package com.budilov.db

import com.budilov.pojo.PictureItem

/**
 * Created by Vladimir Budilov
 *
 */
interface DBPictureService {
    fun get(userId: String, docId: String): PictureItem
    fun delete(userId: String, item: PictureItem): Boolean
    fun search(userId: String, query: String): List<PictureItem>
    fun add(userId: String, item: PictureItem): Boolean
}