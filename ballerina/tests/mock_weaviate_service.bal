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

import ballerina/http;
import ballerinax/weaviate;

listener http:Listener weaviateListener = check new http:Listener(9090);

service / on weaviateListener {
    resource function delete objects/[string path]/[string id]() returns error? {
        if id != "mock-id" {
            return error("This is an error");
        }
    }

    resource function post graphql(weaviate:GraphQLQuery payload) returns weaviate:GraphQLResponse|error {
        return {
            data: {
                "Get": {
                    "Chunk": [
                        {
                            _additional: {
                                certainty: 0.9999999403953552,
                                id: "e7d58e49-4ac6-45ca-a921-e6de941b4d99",
                                vector: [1, 2, 3]
                            },
                            content: "This is a test chunk"
                        },
                        {
                            _additional: {
                                certainty: 0.9999999403953552,
                                id: "121a8352-4cd6-4aea-8897-49c8357682cb",
                                vector: [1, 2, 3]
                            },
                            content: "This is a test chunk"
                        }
                    ]
                }
            }
        };
    }

    resource function post batch/objects(weaviate:Batch_objects_body payload,
            string? consistency_level = ()) returns weaviate:ObjectsGetResponse[]|error {
        return [
            {
                deprecations: null,
                result: {
                    status: "SUCCESS"
                },
                'class: "Chunk",
                properties: {
                    "content": "This is a test chunk",
                    "type": "text"
                },
                id: "mock-id",
                creationTimeUnix: 1754499912863,
                lastUpdateTimeUnix: 1754499912863,
                vector: [1.0, 2.0, 3.0]
            }
        ];
    }
};
