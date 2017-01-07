package com.budilov.db

import com.amazonaws.auth.EnvironmentVariableCredentialsProvider
import com.budilov.pojo.PictureItem
import com.budilov.Properties
import io.searchbox.client.JestClient
import io.searchbox.client.JestClientFactory
import io.searchbox.client.config.HttpClientConfig
import io.searchbox.core.Delete
import io.searchbox.core.Get
import io.searchbox.core.Index
import io.searchbox.core.Search
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

class ESPictureService() : DBPictureService {

    val client: JestClient
    val _MATCH_ALL_QUERY = "{\"query\": { \"match\": { \"labels\": \" REPLACE_ME \" } }, \"size\":30}"

    val _DEFAULT_INDEX = "pictures"

    init {
        val clock = { LocalDateTime.now(ZoneOffset.UTC) }

        // Sig4
        val awsSigner = AWSSigner(EnvironmentVariableCredentialsProvider(), Properties.getRegion(), "es", clock)

        // Adding a request interceptor to sign the ES requests with Sig4
        val requestInterceptor = AWSSigningRequestInterceptor(awsSigner)
        val factory = object : JestClientFactory() {
            override fun configureHttpClient(builder: HttpClientBuilder): HttpClientBuilder {
                builder.addInterceptorLast(requestInterceptor)
                return builder
            }

            override fun configureHttpClient(builder: HttpAsyncClientBuilder): HttpAsyncClientBuilder {
                builder.addInterceptorLast(requestInterceptor)
                return builder
            }
        }

        factory.setHttpClientConfig(HttpClientConfig.Builder(Properties.getESServiceUrl())
                .multiThreaded(true)
                .build())

        client = factory.`object`
    }

    /**
     * Return one PictureItem
     *
     */
    override fun get(userId: String, docId: String): PictureItem {
        val get = Get.Builder(_DEFAULT_INDEX, docId).type(userId).build()

        val result = client.execute(get)

        return result.getSourceAsObject(PictureItem::class.java)
    }

    /**
     * Delete a picture from ES
     */
    override fun delete(userId: String, item: PictureItem): Boolean {

        val delete = client.execute(Delete.Builder(item.id)
                .index(_DEFAULT_INDEX)
                .type(userId)
                .build())

        return delete.isSucceeded
    }

    /**
     * Search for pictures.
     *
     * returns List<PictureItem>
     */
    override fun search(userId: String, query: String): List<PictureItem> {
        val matchAllQuery = _MATCH_ALL_QUERY.replace("REPLACE_ME", query)

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
    override fun add(userId: String, item: PictureItem): Boolean {
        println("Adding picture")
        val index = Index.Builder(item).index(_DEFAULT_INDEX).type(userId).build()
        val result = client.execute(index)

        println("Result error: " + result.errorMessage)
        println("Result id: " + result.id)

        return result.isSucceeded
    }
}