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
import ballerina/test;
import ballerina/uuid;

final VectorStore mockVectorStore = check new (
    serviceUrl = "http://localhost:8080/v1",
    config = {
        collectionName: "Chunk"
    },
    auth = {
        token: "mock-token"
    }
);

@test:Config {}
function testAddingValuesToVectorStore() returns error? {
    ai:VectorEntry[] entries = [
        {
            id: uuid:createRandomUuid(),
            embedding: [1.0, 2.0, 3.0],
            chunk: {
                'type: "text", 
                content: "This is a test chunk"
            }
        }
    ];
    ai:Error? result = mockVectorStore.add(entries);
    test:assertTrue(result !is error);
}

@test:Config {}
function testDeleteValuesFromVectorStore() returns error? {
    ai:Error? result = mockVectorStore.delete("mock-id");
    test:assertTrue(result !is error);
}

@test:Config {}
function testQueryValuesFromVectorStore() returns error? {
    ai:VectorStoreQuery query = {
        filters: {
            filters: [
                {
                    operator: ai:EQUAL,
                    'key: "content",
                    value: "This is a test chunk"
                }
            ]
        }
    };
    ai:VectorMatch[]|ai:Error result = mockVectorStore.query(query);
    test:assertTrue(result !is error);
}

@test:Config {}
function testVectorStoreInitializationWithInvalidURL() returns error? {
    VectorStore store = check new (
        serviceUrl = "invalid-url",
        config = {
            collectionName: "TestChunk"
        },
        auth = {
            token: "test-token"
        }
    );
    ai:VectorMatch[]|ai:Error result = store.query({
        topK: 0,
        embedding: [1.0, 2.0, 3.0]
    });
    test:assertTrue(result is ai:Error);
}

@test:Config {}
function testAddEmptyVectorEntriesArray() returns error? {
    ai:VectorEntry[] emptyEntries = [];
    ai:Error? result = mockVectorStore.add(emptyEntries);
    test:assertTrue(result is error, "");
}

@test:Config {}
function testQueryWithTopKZero() returns error? {
    ai:VectorStoreQuery query = {
        topK: 0,
        embedding: [1.0, 2.0, 3.0]
    };
    ai:VectorMatch[]|ai:Error result = mockVectorStore.query(query);
    test:assertTrue(result is error);
}

@test:Config {}
function testQueryWithNegativeTopK() returns error? {
    ai:VectorStoreQuery query = {
        topK: -5,
        embedding: [1.0, 2.0, 3.0]
    };
    ai:VectorMatch[]|ai:Error result = mockVectorStore.query(query);
    test:assertTrue(result is error);
}
