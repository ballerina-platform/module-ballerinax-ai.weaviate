## Overview

Weaviate is an open-source vector database that stores both objects and vectors, allowing for combining vector search with structured filtering with the scalability of a cloud-native database.

The Ballerina Weaviate vector store module provides a comprehensive API for integrating with Weaviate vector databases, enabling efficient storage, retrieval, and management of high-dimensional vectors. This implementation allows being used as a Ballerina `ai:VectorStore`, providing smooth integration with the Ballerina AI module.

## Set up guide

Before using the Ballerina Weaviate vector store module, you need to set up a Weaviate instance and obtain the necessary credentials.

### Step 1: Create a Weaviate account

You can create an account for free if you don't already have one.

1. Visit [weaviate.io](https://weaviate.io/) and click **Try Now** to sign up for a free account

   <img src="https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-ai.weaviate/main/resources/sign-up-page.png" alt="Sign Up" width="60%">

2. Complete the registration process and verify your email address if required
3. Log in to your new Weaviate account

For more details, refer to the official documentation on [creating a new account](https://docs.weaviate.io/cloud/platform/create-account).


### Step 2: Set up a Weaviate cluster

1. Access the Weaviate Console and click **Create Cluster** to create a new Weaviate instance.

   <img src="https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-ai.weaviate/main/resources/getting-started-page.png" alt="Create Cluster" width="60%">

2. Provide the required details (e.g., Cluster name) and preferred configuration options and confirm.

   <img src="https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-ai.weaviate/main/resources/create-cluster.png" alt="Create Cluster" width="60%">

3. Click **Create** and wait for the cluster to be provisioned (this typically takes 2-3 minutes)

4. Once the cluster is ready, locate and copy the REST endpoint URL from your cluster dashboard. You'll use this URL as the `serviceUrl` in your `weaviate:Client` configuration

For more details, refer to the official documentation on [creating clusters](https://docs.weaviate.io/cloud/manage-clusters/create).

### Step 3: Generate API credentials

1. In the Weaviate Console, navigate to your cluster dashboard and go to the API Keys section
2. Click **Create API Key** and provide a name for the key and create the API key.

   <img src="https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-ai.weaviate/main/resources/create-api-key.png" alt="Create Cluster" width="60%">

3. Securely save the generated API key, which you'll use as the `token` in your `weaviate:Client` configuration.

For more details, refer to the official documentation on [authentication](https://docs.weaviate.io/cloud/manage-clusters/authentication).

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
        collectionName: "add-collection-name"
    }, 
    apiKey = "mock-token"
);
```

### Step 3: Add vectors

```ballerina
ai:Error? result = vectorStore.add(
    [
        {
            id: "1",
            embedding: [1.0, 2.0, 3.0],
            chunk: {
                'type: "text", 
                content: "This is a chunk"
            }
        }
    ]
);
```

## Examples

The Ballerina Weaviate vector store module provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-ai.weaviate/tree/main/examples).

1. [Book recommendation system](https://github.com/ballerina-platform/module-ballerinax-ai.weaviate/tree/main/examples/book-recommendation-system)
   This example shows how to use Weaviate vector store APIs to implement a book recommendation system that stores book embeddings and queries them to find similar books based on vector similarity and metadata filtering.
