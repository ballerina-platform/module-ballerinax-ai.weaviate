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
    # + serviceUrl - The URL of the Weaviate service
    # + config - The configurations containing collection name, topK, and chunk field name
    # + httpConfig - The HTTP configuration for the Weaviate client connection
    # + return - An `ai:Error` if the initialization fails, otherwise returns `()`
    public isolated function init(
            @display {label: "Service URL"} string serviceUrl,
            @display {label: "Weaviate Configuration"} Configuration config,
            @display {label: "HTTP Configuration"} *weaviate:ConnectionConfig httpConfig) returns ai:Error? {
        weaviate:Client|error weaviateClient = new (httpConfig, serviceUrl);
        if weaviateClient is error {
            return error("Failed to initialize weaviate vector store", weaviateClient);
        }
        self.weaviateClient = weaviateClient;
        self.config = config.cloneReadOnly();
        lock {
            string? chunkFieldName = self.config.cloneReadOnly().chunkFieldName;
            self.chunkFieldName = chunkFieldName is () ? "content" : chunkFieldName;
        }
    }

    # Adds a list of vector entries to the Weaviate vector store.
    #
    # + entries - The list of vector entries to add
    # + return - An `ai:Error` if the addition fails, otherwise returns `()`
    public isolated function add(ai:VectorEntry[] entries) returns ai:Error? {
        if entries.length() == 0 {
            return;
        }
        lock {
            weaviate:Object[] objects = [];
            foreach ai:VectorEntry entry in entries.cloneReadOnly() {
                ai:Embedding embedding = entry.embedding;
                weaviate:PropertySchema properties = entry.chunk.metadata !is () ? 
                    check entry.chunk.metadata.cloneWithType() : {};
                properties[self.chunkFieldName] = entry.chunk.content;
                properties["type"] = entry.chunk.'type;

                if embedding is ai:Vector {
                    objects.push({
                        'class: self.config.collectionName,
                        id: entry.id,
                        vector: embedding,
                        properties
                    });
                }
                // TODO: Add support for sparse and hybrid embeddings
                // Weaviate does not support custom sparse or hybrid embeddings directly
                // Need to convert them to dense vectors before adding to Weaviate
            }
            weaviate:ObjectsGetResponse[] _ = check self.weaviateClient->/batch/objects.post({
                objects
            });
        } on fail error err {
            return error("failed to add entries to the vector store", err);
        }
    }

    # Deletes a vector entry from the Weaviate vector store.
    #
    # + ids - One or more identifiers of the vector entries to delete
    # + return - An `ai:Error` if the deletion fails, otherwise returns `()`
    public isolated function delete(string|string[] ids) returns ai:Error? {
        lock {
            string path = self.config.collectionName;
            if ids is string[] {
                transaction {
                    foreach string id in ids.cloneReadOnly() {
                        _ = check deleteById(id, path, self.weaviateClient);
                    }
                    error? commitResult = commit;
                    if commitResult is error {
                        return error("failed to delete vector entries", commitResult);
                    }
                }
                return;
            }
            return deleteById(ids, path, self.weaviateClient);
        }
    }

    # Queries the Weaviate vector store for vector entries.
    #
    # + query - The query containing the embedding, filters, and other search parameters
    # + return - A list of `ai:VectorMatch` objects if the query is successful, otherwise returns an `ai:Error`
    public isolated function query(ai:VectorStoreQuery query) returns ai:VectorMatch[]|ai:Error {
        ai:VectorMatch[] finalMatches;
        lock {
            if query.topK == 0 {
                return error("Invalid value for topK. The value cannot be 0.");
            }
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
                    ${self.config.collectionName}(
                        ${query.topK > -1 ? string `limit: ${query.topK}` : string ``}
                        ${filterSection}
                        ${query.embedding !is () ? 
                            string `nearVector: {
                                vector: ${query.embedding.toJsonString()}
                            }` : string ``
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
                return error("Failed to query vector store", result);
            }
            weaviate:GraphQLError[]? errorResult = result?.errors;
            if errorResult !is () {
                return error("Failed to query vector store: " + errorResult.toJsonString());
            }
            record {|weaviate:JsonObject...;|}? response = result.data;
            if response is () {
                return [];
            }
            weaviate:JsonObject values = response.get("Get");
            anydata data = values.get(string `${self.config.collectionName}`);
            QueryResult[] value = check data.cloneWithType();
            ai:VectorMatch[] matches = [];
            foreach weaviate:JsonObject element in value {
                matches.push({
                    id: element._additional.id,
                    embedding: element._additional.vector,
                    chunk: {
                        'type: element.'type is () ? "" : check element.'type.cloneWithType(),
                        content: element.content
                    },
                    similarityScore: element._additional.certainty !is () ? 
                        check element._additional.certainty.cloneWithType() : 0.0
                });
            }    
            finalMatches = matches.cloneReadOnly();
        } on fail error err {
            return error("failed to query vector store", err);
        }
        return finalMatches;
    }
}

isolated function deleteById(string id, string path, weaviate:Client weaviateClient) returns ai:Error? {
    lock {
        http:Response|error result = weaviateClient->/objects/[path]/[id].delete();
        if result is error {
            return error("failed to delete entry from the vector store", result);
        }
    }
}
