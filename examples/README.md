## Examples

The Ballerina Weaviate vector store module provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-ai.weaviate/tree/main/examples).

1. [Book Recommendation System](https://github.com/ballerina-platform/module-ballerinax-ai.weaviate/tree/main/examples/book-recommendation-system)
   This example shows how to use Weaviate vector store APIs to implement a book recommendation system that stores book embeddings and queries them to find similar books based on vector similarity and metadata filtering.

## Prerequisites

1. Follow the [instructions](https://github.com/ballerina-platform/module-ballerinax-ai.weaviate#set-up-guide) to set up the Weaviate cluster and obtain API credentials.

2. For each example, create a `Config.toml` file with your Weaviate service URL, collection name, and API token. Here's an example of how your `Config.toml` file should look:

   ```toml
   serviceUrl = "<Your Weaviate Service URL>"
   collectionName = "<Your Collection Name>"
   token = "<Your API Token>"
   ```

## Running an Example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the Examples with the Local Module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```
