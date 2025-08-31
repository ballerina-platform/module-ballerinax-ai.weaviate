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

type BookEntry record {
    float[] embedding;
    string title;
    string genre;
};

public function main() returns error? {
    weaviate:VectorStore vectorStore = check new (serviceUrl, {
        collectionName
    }, {
        auth: {
            token
        }
    });

    BookEntry[] entries = [
        {
            title: "A Game of Thrones",
            genre: "Fantasy",
            embedding: [0.1011, 0.20012, 0.3024]
        },
        {
            title: "Crime And Punishment",
            genre: "Literary fiction",
            embedding: [0.98543, 0.347843, 0.845395]
        },
        {
            title: "1984",
            genre: "Science fiction",
            embedding: [0.5645, 0.574, 0.3384]
        }
    ];

    ai:Error? addResult = vectorStore.add(from BookEntry entry in entries
        select {
            id: uuid:createRandomUuid(),
            embedding: entry.embedding,
            chunk: {
                'type: "text",
                content: entry.title,
                metadata: {
                    "genre": entry.genre
                }
            }
        }
    );
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
