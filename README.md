# Ballerina Weaviate Vector Store Library

[![Build](https://github.com/ballerina-platform/module-ballerinax-ai.weaviate/workflows/Build/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-ai.weaviate/actions?query=workflow%3ACI)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-ai.weaviate.svg)](https://github.com/ballerina-platform/module-ballerinax-ai.weaviate/commits/master)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Overview

Weaviate is an open-source vector database that stores both objects and vectors, allowing for combining vector search with structured filtering with the scalability of a cloud-native database.

The Ballerina Weaviate vector store module provides a comprehensive API for integrating with Weaviate vector databases, enabling efficient storage, retrieval, and management of high-dimensional vectors. This implementation allows being used as a Ballerina AI `ai:VectorStore`, providing smooth integration with the Ballerina AI module.

## Set up guide

Before using the Ballerina Weaviate vector store module, you need to set up a Weaviate instance and obtain the necessary credentials.

### Step 1: Create a Weaviate account

You can create an account for free if you don't already have one.

1. Visit [weaviate.io](https://weaviate.io/) and click **Try Now** to sign up for a free account

   <img src="https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-ai.weaviate/main/ballerina/sign-up-page.png" alt="Sign Up" width="60%">

2. Complete the registration process and verify your email address if required
3. Log in to your new Weaviate account

### Step 2: Set up a Weaviate cluster

1. Access the Weaviate Console and click **Create Cluster** to create a new Weaviate instance.

   <img src="https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-ai.weaviate/main/ballerina/getting-started-page.png" alt="Create Cluster" width="60%">

2. Provide the required details (e.g., Cluster name) and preferred configuration options and confirm.

   <img src="https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-ai.weaviate/main/ballerina/create-cluster.png" alt="Create Cluster" width="60%">

3. Click **Create** and wait for the cluster to be provisioned (this typically takes 2-3 minutes)
4. Once the cluster is ready, locate and copy the REST endpoint URL from your cluster dashboard. You'll use this URL as the `serviceUrl` in your `weaviate:Client` configuration

### Step 3: Generate API credentials

1. In the Weaviate Console, navigate to your cluster dashboard and go to the API Keys section
2. Click **Create API Key** and provide a name for the key and create the API key.

   <img src="https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-ai.weaviate/main/ballerina/create-api-key.png" alt="Create Cluster" width="60%">

3. Securely save the generated API key, which you'll use as the `token` in your `weaviate:Client` configuration.

## Quick Start

To use the weaviate vector store in your Ballerina project, modify the `.bal` file as follows.

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
   auth = {
      token: "add-access-token"
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
