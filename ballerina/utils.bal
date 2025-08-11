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

isolated function convertWeaviateFilters(ai:MetadataFilters filters) returns map<anydata>|ai:Error {
    (ai:MetadataFilters|ai:MetadataFilter)[]? rawFilters = filters.filters;
    if rawFilters == () || rawFilters.length() == 0 {
        return {};
    }
    map<anydata>[] filterList = [];
    foreach (ai:MetadataFilters|ai:MetadataFilter) filter in rawFilters {
        if filter is ai:MetadataFilter {
            map<anydata> filterMap = {};
            string weaviateOp = check mapWeaviateOperator(filter.operator);
            filterMap["path"] = [filter.key];
            filterMap["operator"] = weaviateOp;
            filterMap["valueText"] = filter.value;
            filterList.push(filterMap);
            continue;
        }
        map<anydata> nestedFilter = check convertWeaviateFilters(filter);
        if nestedFilter.length() > 0 {
            filterList.push(nestedFilter);
        }
    }
    if filterList.length() == 0 {
        return {};
    }
    if filterList.length() == 1 {
        return filterList[0];
    }
    string weaviateCondition = check mapWeaviateCondition(filters.condition);
    map<anydata> result = {"operator": weaviateCondition, "operands": filterList};
    return result;
}

isolated function mapWeaviateOperator(string operation) returns string|ai:Error {
    match operation {
        "==" => {
            return "Equal";
        }
        "!=" => {
            return "NotEqual";
        }
        ">" => {
            return "GreaterThan";
        }
        ">=" => {
            return "GreaterThanEqual";
        }
        "<" => {
            return "LessThan";
        }
        "<=" => {
            return "LessThanEqual";
        }
        _ => {
            return error ai:Error("Unsupported operator for Weaviate: " + operation);
        }
    }
}

isolated function mapWeaviateCondition(string condition) returns string|ai:Error {
    match condition.toUpperAscii() {
        "AND" => {
            return "And";
        }
        "OR" => {
            return "Or";
        }
        _ => {
            return error ai:Error("Unsupported logical condition for Weaviate: " + condition);
        }
    }
}

isolated function mapToGraphQLObjectString(map<anydata> filter) returns string {
    string result = "{";
    boolean first = true;
    foreach anydata [k, v] in filter.entries() {
        if !first {
            result += ", ";
        }
        first = false;
        result += k + ": ";
        if v is string[] {
            string resultArr = "";
            int i = 0;
            foreach string s in v {
                resultArr += string `"${s}"`;
                if i < v.length() - 1 {
                    resultArr += ", ";
                }
                i += 1;
            }
            result += "[" + resultArr + "]";
        } else if v is map<anydata> {
            result += mapToGraphQLObjectString(v);
        } else if v is map<anydata>[] {
            string resultArr = "";
            int i = 0;
            foreach map<anydata> m in v {
                resultArr += mapToGraphQLObjectString(m);
                if i < v.length() - 1 {
                    resultArr += ", ";
                }
                i += 1;
            }
            result += "[" + resultArr + "]";
        } else if v is string {
            if k == "operator" {
                result += v;
            } else {
                result += string `"${v}"`;
            }
        } else {
            result += v.toString();
        }
    }
    result += "}";
    return result;
}
