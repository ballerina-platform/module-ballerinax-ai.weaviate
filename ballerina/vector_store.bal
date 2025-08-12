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
    private final Configuration config;
    private final string chunkFieldName;
    private final int topK;

    # Initializes the Weaviate vector store with the given configuration.
    #
    public isolated function init(
            @display {label: "Service URL"} string serviceUrl,
            @display {label: "Weaviate Configuration"} Configuration config,
            @display {label: "HTTP Configuration"} weaviate:ConnectionConfig httpConfig) returns ai:Error? {
        weaviate:Client|error weaviateClient = new (httpConfig, serviceUrl);
        if weaviateClient is error {
            return error("Failed to initialize weaviate vector store", weaviateClient);
        }
        self.weaviateClient = weaviateClient;
        self.config = config.cloneReadOnly();
        self.topK = self.config.topK;
        lock {
            string? chunkFieldName = self.config.cloneReadOnly().chunkFieldName;
            self.chunkFieldName = chunkFieldName is () ? "content" : chunkFieldName;
        }
    }

    public isolated function add(ai:VectorEntry[] entries) returns ai:Error? {
        if entries.length() == 0 {
            return;
        }
        lock {
            weaviate:Object[] objects = [];
            foreach ai:VectorEntry entry in entries.cloneReadOnly() {
                ai:Embedding embedding = entry.embedding;
                if embedding is ai:Vector {
                    objects.push({
                        'class: self.config.className,
                        id: entry.id,
                        vector: embedding,
                        properties: {
                            "type": entry.chunk.'type,
                            [self.chunkFieldName]: entry.chunk.content
                        }
                    });
                }
                // TODO: Add support for sparse and hybrid embeddings
                // Weaviate does not support custom sparse or hybrid embeddings directly
                // Need to convert them to dense vectors before adding to Weaviate
            }
            weaviate:ObjectsGetResponse[]|error result = self.weaviateClient->/batch/objects.post({
                objects
            });
            if result is error {
                return error("Failed to add vector entries", result);
            }
        }
    }

    public isolated function delete(string id) returns ai:Error? {
        lock {
            string path = self.config.className;
            http:Response|error result = self.weaviateClient->/objects/[path]/[id].delete();
            if result is error {
                return error("Failed to query vector store", result);
            }
        }
    }

    public isolated function query(ai:VectorStoreQuery query) returns ai:VectorMatch[]|ai:Error {
        ai:VectorMatch[] finalMatches;
        lock {
            string filterSection = "";
            if query.hasKey("filters") && query.filters is ai:MetadataFilters {
                ai:MetadataFilters? filters = query.cloneReadOnly().filters;
                if filters !is () {
                    map<anydata> weaviateFilter = check convertWeaviateFilters(filters);
                    filterSection = "where: " + mapToGraphQLObjectString(weaviateFilter);
                }
            }
            string gqlQuery = string `{
                Get {
                    ${self.config.className}(
                        limit: ${self.topK}
                        ${filterSection}
                        nearVector: {
                            vector: ${query.embedding.toJsonString()}
                        }
                    ) {
                        content
                        _additional {
                            certainty
                            id
                            vector
                        }
                    }
                }
            }`;
            weaviate:GraphQLResponse|error result = self.weaviateClient->/graphql.post({
                query: gqlQuery
            });
            if result is error {
                return error ai:Error("Failed to query vector store", result);
            }
            weaviate:GraphQLError[]? errorResult = result?.errors;
            if errorResult !is () {
                return error ai:Error("Failed to query vector store: " + errorResult.toJsonString());
            }

            record {|weaviate:JsonObject...;|}? response = result.data;
            if response is () {
                return [];
            }
            weaviate:JsonObject values = response.get("Get");
            anydata res = values.get(string `${self.config.className}`);
            QueryResult[] val = check res.cloneWithType();
            ai:VectorMatch[] matches = [];
            foreach weaviate:JsonObject element in val {
                matches.push({
                    id: element._additional.id,
                    embedding: element._additional.vector,
                    chunk: {
                        'type: element.'type is () ? "" : check element.'type.cloneWithType(),
                        content: element.content
                    },
                    similarityScore: element._additional.certainty
                });
            } on fail error e {
                return error ai:Error("Failed to parse vector store query", e);
            }
            finalMatches = matches.cloneReadOnly();
        } on fail var e {
            return error ai:Error("Failed to query vector store", e);
        }
        return finalMatches;
    }
}
