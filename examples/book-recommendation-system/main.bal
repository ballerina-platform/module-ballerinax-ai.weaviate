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
import ballerina/io;
import ballerina/uuid;
import ballerinax/ai.weaviate;

configurable string serviceUrl = ?;
configurable string collectionName = ?;
configurable string token = ?;

public function main() returns error? {
    weaviate:VectorStore vectorStore = check new (serviceUrl, {
        collectionName
    }, {
        auth: {
            token
        }
    });

    // This is the embedding of a sample book entry
    ai:Vector bookEmbedding = [0.1, 0.2, 0.3];

    ai:Error? addResult = vectorStore.add([
        {
            id: uuid:createRandomUuid(),
            embedding: bookEmbedding,
            chunk: {
                'type: "text",
                content: "A Game of Thrones",
                metadata: {
                    "genre": "Fantasy"
                }
            }
        }
    ]);

    if addResult is ai:Error {
        io:println("Error occurred while adding an entry to the vector store", addResult);
        return;
    }

    // This is the embedding of the search query. It should use the same model as the embedding of the book entries.
    ai:Vector searchEmbedding = [0.05, 0.1, 0.15];

    ai:VectorMatch[] query = check vectorStore.query({
        embedding: searchEmbedding,
        filters: {
            filters: [
                {
                    'key: "genre",
                    operator: ai:EQUAL,
                    value: "Fantasy"
                }
            ]
        }
    });
    io:println("Query Results: ", query);
}
