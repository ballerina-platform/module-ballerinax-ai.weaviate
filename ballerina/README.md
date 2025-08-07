# Ballerina Weaviate Vector Store Module

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

In the Weaviate Console, navigate to your cluster settings. And Generate an API key for authentication. Copy the API key and cluster URL for use in your application.

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
