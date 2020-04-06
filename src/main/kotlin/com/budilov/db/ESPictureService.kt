package com.budilov.db

import com.amazonaws.auth.EnvironmentVariableCredentialsProvider
import com.budilov.Properties
import com.budilov.pojo.PictureItem
import io.searchbox.client.JestClient
import io.searchbox.client.JestClientFactory
import io.searchbox.client.config.HttpClientConfig
import io.searchbox.core.*
import org.apache.http.impl.client.HttpClientBuilder
import org.apache.http.impl.nio.client.HttpAsyncClientBuilder
import vc.inreach.aws.request.AWSSigner
import vc.inreach.aws.request.AWSSigningRequestInterceptor
import java.time.LocalDateTime
import java.time.ZoneOffset


/**
 * Created by Vladimir Budilov
 *
 * Simple DAO implementation for ElasticSearch
 *
 */

class ESPictureService {

    private val client: JestClient

    private val _DEFAULT_INDEX = "pictures"

    init {
        val clock = { LocalDateTime.now(ZoneOffset.UTC) }

        // Sig4
        val awsSigner = AWSSigner(EnvironmentVariableCredentialsProvider(), Properties._REGION, "es", clock)

        // Adding a request interceptor to sign the ES requests with Sig4
        val factory = getJestFactory(AWSSigningRequestInterceptor(awsSigner))

        factory.setHttpClientConfig(HttpClientConfig.Builder(Properties._ES_SERVICE_URL)
                .multiThreaded(true)
                .build())

        client = factory.`object`
    }

    /**
     * Return one PictureItem
     *
     */
    fun get(userId: String, docId: String): PictureItem {
        val get = Get.Builder(_DEFAULT_INDEX, docId).type(userId).build()

        val result = client.execute(get)

        return result.getSourceAsObject(PictureItem::class.java)
    }

    /**
     * Delete a picture from ES
     */
    fun delete(userId: String, item: PictureItem): Boolean {

        val delete = client.execute(Delete.Builder(item.id)
                .index(_DEFAULT_INDEX)
                .type(userId)
                .build())

        return delete.isSucceeded
    }

    fun deleteByCustomId(userId: String, item: PictureItem): Boolean {

        val query = """ 
            "query": { 
                "match": {
                  "id": "${item.id}"
                } 
            }
        """

        println("deleteByCustomId query \n $query ")
        val deleteByCustomValue = DeleteByQuery.Builder(query)
                .addIndex(_DEFAULT_INDEX)
                .addType(userId)
                .build()

//        println("deleteByCustomId uri: ${deleteByCustomValue?.uri}")
        client.execute(deleteByCustomValue)

        //TODO: fix this up
        return true
    }

    /**
     * Search for pictures.
     *
     * returns List<PictureItem>
     */
    fun search(userId: String, query: String): List<PictureItem> {
        val matchAllQuery = getMatchAllQuery(query)

        val search = Search.Builder(matchAllQuery)
                // multiple index or types can be added.
                .addIndex(_DEFAULT_INDEX)
                .addType(userId)
                .build()

        val result = client.execute(search)

        return result.getSourceAsObjectList(PictureItem::class.java)
    }

    /**
     * Add a picture
     *
     * For now it always returns true
     */
    fun add(userId: String, item: PictureItem): Boolean {
        val index = Index.Builder(item)
                .index(_DEFAULT_INDEX)
                .type(userId)
                .id(item.id)
                .build()
        val result = client.execute(index)

        println("added item with id of ${result?.id}")
        return result.isSucceeded
    }

    private fun getMatchAllQuery(labels: String, pageSize: Int = 30): String {
        return """{"query": { "match": { "labels": "$labels" } }, "size":$pageSize}"""
    }

    private fun getJestFactory(requestInterceptor: AWSSigningRequestInterceptor): JestClientFactory {
        return object : JestClientFactory() {
            override fun configureHttpClient(builder: HttpClientBuilder): HttpClientBuilder {
                builder.addInterceptorLast(requestInterceptor)
                return builder
            }

            override fun configureHttpClient(builder: HttpAsyncClientBuilder): HttpAsyncClientBuilder {
                builder.addInterceptorLast(requestInterceptor)
                return builder
            }
        }
    }
}