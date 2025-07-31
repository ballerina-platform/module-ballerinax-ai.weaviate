// Copyright (c) 2025 WSO2 LLC (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/ai;
import ballerina/http;
import ballerinax/weaviate;

# Weaviate Vector Store implementation with support for Dense, Sparse, and Hybrid vector search modes.
#
# This class implements the ai:VectorStore interface and integrates with the Weaviate vector database
# to provide functionality for vector upsert, query, and deletion.
# 
public isolated class VectorStore {
    *ai:VectorStore;

    private final weaviate:Client weaviateClient;
    private final ai:VectorStoreQueryMode queryMode;
    private final ai:MetadataFilters filters;

    # Initializes the Weaviate vector store with the given configuration.
    #
    public isolated function init(@display {label: "Service URL"} string serviceUrl, 
            @display {label: "API Key"} string apiKey, 
            @display {label: "HTTP Configuration"} weaviate:ConnectionConfig weaviateConfig,
            @display {label: "Weaviate Configuration"} Configuration config = {}, 
            @display {label: "Query Mode"} ai:VectorStoreQueryMode queryMode = ai:DENSE) returns ai:Error? {
        weaviate:Client|error weaviateClient = new (weaviateConfig, serviceUrl);
        if weaviateClient is error {
            return error("Failed to initialize weaviate vector store", weaviateClient);
        }
        self.weaviateClient = weaviateClient;
        self.queryMode = queryMode;
        self.filters = config.filters.clone() ?: {filters: []};
    }

    public isolated function add(ai:VectorEntry[] entries) returns ai:Error? {
        if entries.length() == 0 {
            return;
        }
        weaviate:Object[] objects = [];
        foreach ai:VectorEntry entry in entries {
            objects.push({
                'class: "Document",
                id: entry.id,
                properties: {
                    "type": entry.chunk.'type,
                    "content": entry.chunk.content
                }
            });
        }
        weaviate:ObjectsGetResponse[]|error result = self.weaviateClient->/batch/objects.post({
            objects
        });
        if result is error {
            return error("Failed to add vector entries", result);
        }
    }

    public isolated function delete(string id) returns ai:Error? {
        http:Response|error result = self.weaviateClient->/objects/["path"]/id.delete();
        if result is error {
            return error ai:Error("Failed to query vector store", result);
        }
    }

    public isolated function query(ai:VectorStoreQuery query) returns ai:VectorMatch[]|ai:Error {
        return [];
    }
}
