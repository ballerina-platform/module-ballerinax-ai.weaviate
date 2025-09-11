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
import ballerina/time;

# Converts metadata filters to Weaviate compatible filter format
#
# + filters - The metadata filters containing filter conditions and logical operators
# + metadataFields - The fields of the metadata to be filtered
# + return - A map representing the converted filter structure or an error if conversion fails
isolated function convertWeaviateFilters(ai:MetadataFilters filters, string[] metadataFields) returns map<anydata>|ai:Error {
    (ai:MetadataFilters|ai:MetadataFilter)[]? rawFilters = filters.filters;
    if rawFilters == () || rawFilters.length() == 0 {
        return {};
    }
    map<anydata>[] filterList = [];
    foreach (ai:MetadataFilters|ai:MetadataFilter) filter in rawFilters {
        if filter is ai:MetadataFilter {
            metadataFields.push(filter.key);
            map<anydata> filterMap = {};
            string weaviateOp = check mapWeaviateOperator(filter.operator);
            filterMap["path"] = [filter.key];
            filterMap["operator"] = weaviateOp;
            json value = filter.value;
            if value is time:Utc {
                filterMap["valueDate"] = string `"${time:utcToString(value)}"`;
            } else if value is int|float|decimal {
                filterMap["valueNumber"] = value;
            } else {
                filterMap["valueText"] = string `"${value.toString()}"`;
            }
            filterList.push(filterMap);
            continue;
        }
        map<anydata> nestedFilter = check convertWeaviateFilters(filter, metadataFields);
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
    return {
        operator: weaviateCondition, 
        operands: filterList
    };
}

# Maps metadata filter operators to Weaviate compatible operators
#
# + operation - The metadata filter operator to map
# + return - The Weaviate compatible operator or an error if the operator is not supported
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
    }
    return error ai:Error("Unsupported operator for Weaviate: " + operation);
}

# Maps metadata logical conditions to Weaviate compatible conditions
#
# + condition - The metadata logical condition to map
# + return - The Weaviate compatible condition or an error if the condition is not supported
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

# Converts a map to a GraphQL compatible string representation
#
# + filter - The map to convert
# + return - The GraphQL compatible string representation of the map
isolated function mapToGraphQLObjectString(map<anydata> filter) returns string {
    string result = "{";
    boolean first = true;
    foreach anydata ['key, value] in filter.entries() {
        if !first {
            result += ", ";
        }
        first = false;
        result += 'key + ": ";
        if value is string[] {
            string resultArr = "";
            int index = 0;
            foreach string element in value {
                resultArr += string `"${element}"`;
                if index < value.length() - 1 {
                    resultArr += ", ";
                }
                index += 1;
            }
            result += "[" + resultArr + "]";
        } else if value is map<anydata> {
            result += mapToGraphQLObjectString(value);
        } else if value is map<anydata>[] {
            string resultArr = "";
            int index = 0;
            foreach map<anydata> m in value {
                resultArr += mapToGraphQLObjectString(m);
                if index < value.length() - 1 {
                    resultArr += ", ";
                }
                index += 1;
            }
            result += "[" + resultArr + "]";
        } else if value is string {
            result += 'key == "operator" ? value : string `${value}`;
        } else {
            result += value.toString();
        }
    }
    result += "}";
    return result;
}
