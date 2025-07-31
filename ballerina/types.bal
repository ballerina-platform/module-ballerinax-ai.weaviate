import ballerina/ai;

# Represents the configuration options for interacting with a Weaviate vector store.
public type Configuration record {
    # Optional namespace to isolate vectors within Weaviate
    string namespace?;
    # Metadata filters applied during search
    ai:MetadataFilters filters?;
    # Optional sparse vector for hybrid search operations
    ai:SparseVector sparseVector?;
    # Number of top similar vectors to return in queries
    int topK = 5;
};