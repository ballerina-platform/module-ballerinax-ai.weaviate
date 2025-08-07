# Ballerina Weaviate Vector Store Library

[![Build](https://github.com/ballerina-platform/module-ballerinax-ai.weaviate/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-ai.weaviate/actions?query=workflow%3ACI)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-ai.weaviate.svg)](https://github.com/ballerina-platform/module-ballerinax-ai.weaviate/commits/master)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Overview

The Ballerina Weaviate vector store module provides a comprehensive API for integrating with Weaviate vector database, enabling efficient storage, retrieval, and management of high-dimensional vectors. This module implements the Ballerina AI `VectorStore` interface and supports multiple vector search algorithms.

## Set up guide

### Step 1: Create a Weaviate account

Navigate to [Weaviate.io](https://weaviate.io/) and create a free account

### Step 2: Set up Weaviate instance

Access the [Weaviate Console](https://console.weaviate.cloud/)
Create a new cluster
Use the REST endpoint as the `serviceUrl`.

### Step 3: Generate API credentials

In the Weaviate Console, navigate to your cluster settings. And Generate an API key for authentication. Copy the API key and cluster URL for use in your application

## Quick Start

### Step 1: Import the module

```ballerina
import ballerina/ai;
import ballerinax/ai.weaviate;
```

### Step 2: Initialize the Weaviate vector store

```ballerina
ai:VectorStore vectorStore = check new weaviate:VectorStore(
    serviceUrl = "add-weaviate-service-url", 
    config = {
        className: "add-collection-name"
    }, 
    httpConfig = {
        auth: {
            token: "add-access-token"
        }
    }
);
```

### Step 3: Add vectors

```ballerina
ai:Error? result = vectorStore.add(
    [
        {
            id: uuid:createRandomUuid(),
            embedding: [1.0, 2.0, 3.0],
            chunk: {
                'type: "text", 
                content: "This is a chunk"
            }
        }
    ]
);
```

## Issues and projects

Issues and Projects tabs are disabled for this repository as this is part of the Ballerina Library. To report bugs, request new features, start new discussions, view project boards, etc., go to the [Ballerina Library parent repository](https://github.com/ballerina-platform/ballerina-standard-library).
This repository only contains the source code for the module.

## Build from the source

### Prerequisites

1. Download and install Java SE Development Kit (JDK) version 21 (from one of the following locations).

   - [Oracle](https://www.oracle.com/java/technologies/downloads/)
   - [OpenJDK](https://adoptium.net/)

     > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed JDK.

2. Generate a GitHub access token with read package permissions, then set the following `env` variables:

   ```shell
   export packageUser=<Your GitHub Username>
   export packagePAT=<GitHub Personal Access Token>
   ```

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To run a group of tests

   ```bash
   ./gradlew clean test -Pgroups=<test_group_names>
   ```

4. To build the without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

5. To debug the package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina central repository:

   ```bash
   ./gradlew clean build -PpublishToLocalCentral=true
   ```

8. Publish the generated artifacts to the Ballerina central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).
