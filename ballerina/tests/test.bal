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
import ballerina/time;
import ballerina/uuid;
import ballerina/http;

final VectorStore mockVectorStore = check new (
    serviceUrl = "http://localhost:8080",
    config = {
        collectionName: "Test"
    },
    apiKey = "mock-token"
);

@test:BeforeSuite
function beforeSuite() returns error? {
    http:Client httpClient = check new ("http://localhost:8080");
    http:Response _ = check httpClient->post(path = "/v1/schema", headers =  {
            "Content-Type": "application/json"
        }, message = {
            "class": "Test",
            "properties": [
                { "name": "content", "dataType": ["text"] },
                { "name": "type", "dataType": ["string"] },
                { "name": "createdAt", "dataType": ["date"] }
            ]
        });
}


string id = uuid:createRandomUuid();
time:Utc createdAt = time:utcNow();

@test:Config {}
function testAddingValuesToVectorStore() returns error? {
    ai:VectorEntry[] entries = [
        {
            id,
            embedding: [1.0, 2.0, 3.0],
            chunk: {
                'type: "text",
                content: "This is a test chunk",
                metadata: {
                    createdAt
                }
            }
        }
    ];
    ai:Error? result = mockVectorStore.add(entries);
    test:assertTrue(result !is error);
}

@test:Config {}
function testDeleteValueFromVectorStore() returns error? {
    ai:Error? result = mockVectorStore.delete(id);
    test:assertTrue(result !is error);
}

@test:Config {}
function testDeleteMultipleValuesFromVectorStore() returns error? {
    string index = uuid:createRandomUuid();
    ai:VectorEntry[] entries = [
        {
            id: index,
            embedding: [1.0, 2.0, 3.0],
            chunk: {
                'type: "text",
                content: "This is a test chunk"
            }
        }
    ];
    _ = check mockVectorStore.add(entries);
    ai:Error? result = mockVectorStore.delete([id, index]);
    test:assertTrue(result !is error);
}

@test:Config {
    dependsOn: [testAddingValuesToVectorStore]
}
function testQueryValuesFromVectorStore() returns error? {
    ai:VectorStoreQuery query = {
        filters: {
            filters: [
                {
                    'key: "createdAt",
                    operator: ai:EQUAL,
                    value: createdAt
                },
                {
                    'key: "content",
                    operator: ai:EQUAL,
                    value: "This is a test chunk"
                }
            ]
        }
    };
    ai:VectorMatch[] result = check mockVectorStore.query(query);
    test:assertTrue(result.length() > 0);
    test:assertEquals(result[0].chunk.metadata?.createdAt, createdAt);
}

@test:Config {}
function testVectorStoreInitializationWithInvalidURL() returns error? {
    VectorStore store = check new (
        serviceUrl = "invalid-url",
        config = {
            collectionName: "TestChunk"
        },
        apiKey = "test-token"
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
