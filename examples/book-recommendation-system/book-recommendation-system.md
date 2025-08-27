# Book recommendation system with Weaviate vector store

This example demonstrates the use of the Ballerina Weaviate vector store module for building a book recommendation system. The system stores book embeddings and queries them to find similar books based on vector similarity and metadata filtering.

## Step 1: Import the modules

Import the required modules for AI operations, I/O operations, UUID generation, and Weaviate vector store.

```ballerina
import ballerina/ai;
import ballerina/io;
import ballerina/uuid;
import ballerinax/ai.weaviate;
```

## Step 2: Configure the application

Set up configurable variables for Weaviate connection parameters.

```ballerina
configurable string serviceUrl = ?;
configurable string collectionName = ?;
configurable string token = ?;
```

## Step 3: Create a vector store instance

Initialize the Weaviate vector store with your service URL, collection name, and authentication token.

```ballerina
weaviate:VectorStore vectorStore = check new (serviceUrl, {
    collectionName
}, {
    auth: {
        token
    }
});
```

Now, the `weaviate:VectorStore` instance can be used for storing and querying book embeddings.

## Step 4: Add book embeddings to the vector store

Store book information with their vector embeddings and metadata in the Weaviate vector store.

```ballerina
// This is the embedding of a sample book entry
ai:Vector bookEmbedding = [0.1, 0.2, 0.3];

ai:Error? addResult = vectorStore.add([
    {
        id: uuid:createRandomUuid(),
        embedding: bookEmbedding,
        chunk: {
            'type: "text",
            content: "A Game of Thrones",
            metadata: {
                "genre": "Fantasy"
            }
        }
    }
]);

if addResult is ai:Error {
    io:println("Error occurred while adding an entry to the vector store", addResult);
    return;
}
```

## Step 5: Query for book recommendations

Search for similar books using vector similarity and apply metadata filters to refine the results.

```ballerina
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
```

## Step 6: Understanding the results

The query results contain book recommendations with similarity scores and metadata. Each result includes:

- **id**: Unique identifier for the book entry
- **embedding**: The vector representation of the book
- **chunk**: Contains the book information including type, content, and metadata
- **similarityScore**: How similar the book is to your search query (higher scores indicate better matches)

The system can be extended to,

- Add more books with richer metadata (author, publication year, ISBN, etc.)
- Use real embeddings from language models instead of sample vectors
- Implement more complex filtering logic
- Build a REST API around the recommendation system
