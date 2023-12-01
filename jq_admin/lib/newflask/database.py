from config import LABEL_ENCODER, SVM_MODEL
from dictionary import fields_list
from pymilvus import (
    MilvusException,
    DataType,
    Collection,
)
import os


def similarity_search(
    name, vectors, search_params, partition_names, limit, consistency_level
):
    """
    Searches a collection in Milvus based on the given parameters.
    """
    results = None
    try:
        collection = Collection(f"{name}_collection")
        collection.load()
        output_fields = ["uuid", "text_id"] if name == "text" else ["uuid"]
        results = collection.search(
            data=[vectors],
            anns_field="embeds",
            param=search_params,
            limit=limit,
            partition_names=partition_names,
            output_fields=output_fields,
            consistency_level=consistency_level,
        )
    except MilvusException as e:
        if "partition name" in str(e) and "not found" in str(e):
            print(
                f"Partition '{partition_names}' not found in collection '{name}', skipping..."
            )
        else:
            raise
    print("similarity search done")
    return results


def search_collections(vectors, partition_names):
    results_dict = {}
    search_params = {
        "metric_type": "L2",  # Distance metric, L2, IP, etc.
        "offset": 0,
    }
    limit = 10
    consistency_level = "Strong"

    for name in fields_list:
        result = similarity_search(
            name, vectors, search_params, partition_names, limit, consistency_level
        )
        if result is not None:
            results_dict[name] = result
    print("search_collecrions done")
    return results_dict


def check_collection_dimension(collection):
    collection_params = collection.schema
    vector_field = [
        field
        for field in collection_params.fields
        if field.dtype == DataType.FLOAT_VECTOR
    ][0]
    print(
        f"Dimension of vectors in collection '{collection.name}': {vector_field.params['dim']}"
    )
    print(f"Checked collection dimension for '{collection.name}'")


def process_hit(hit, collection_name):
    """
    Process a single hit and returns a result dictionary.
    """
    id_value = hit.entity.get("text_id") if collection_name == "text" else hit.id
    result_dict = {
        "entity_id": id_value,
        "distance": hit.distance,
        "collection": collection_name,
    }
    print(f"Processed a hit for collection '{collection_name}'")
    return result_dict


def update_insert_results(result_dict, json_results):
    """
    Update or insert the result into the results dictionary.
    """
    id_value = result_dict["entity_id"]

    # If the id_value is already in the results and the new distance is greater, skip
    if (
        id_value in json_results
        and json_results[id_value]["distance"] <= result_dict["distance"]
    ):
        return

    # Otherwise, update/insert the result
    json_results[id_value] = result_dict
    print(f"Updated or inserted results for entity_id '{id_value}'")


def sort_results(results_dict):
    json_results = {}

    for collection_name, result in results_dict.items():
        for query_hits in result:
            for hit in query_hits:
                result_dict = process_hit(hit, collection_name)
                update_insert_results(result_dict, json_results)

    # Convert the results to a list and sort them by distance
    json_results_list = list(json_results.values())
    json_results_sorted = sorted(
        json_results_list, key=lambda x: x["distance"], reverse=True
    )
    print("sort_results done")
    return json_results_sorted


def initialize_collections():
    """
    Load all collections and return a dictionary mapping field names to collections.
    """
    print("Initialized all collections")
    return {name: Collection(f"{name}_collection") for name in fields_list}


def extract_entity_ids(results):
    """
    Create a list of entity IDs from the results.
    """
    print("Extracted entity_ids from results")
    return [result["entity_id"] for result in results]


def prepare_result_fields(results):
    """
    Prepare an empty list for each field in each result entry.
    """
    for result in results:
        for name in fields_list:
            result[name] = []
    print("Prepared result fields for each result entry")


def query_collections(collections, entity_ids, partition_names):
    """
    Query each collection for the specified entity IDs and return the query results.
    """
    query_results = {}
    for name, collection in collections.items():
        query_field = "text_id" if name == "text" else "uuid"
        output_fields = [name, "text_id", "media", "link"] if name == "text" else [name]
        query = f"{query_field} in {entity_ids}"

        try:
            query_results[name] = collection.query(
                expr=query,
                offset=0,
                limit=len(entity_ids),
                partition_names=[partition_names],
                output_fields=output_fields,
                consistency_level="Strong",
            )
        except Exception as e:
            print(f"Error with collection {name}: {str(e)}")
    print("Queried all collections for specified entity_ids")
    return query_results


def update_results_with_query_data(results, query_results):
    """
    Update the results with data from the query results, appending 'link' and 'media' fields
    from the 'text' collection to the 'text' field.
    """
    for name, collection_results in query_results.items():
        for query_result in collection_results:
            for result in results:
                entity_id = result["entity_id"]

                if name == "text" and entity_id == query_result["text_id"]:
                    # Append text, link, and media if they exist
                    result["text"].append(query_result.get("text", ""))
                    if "link" in query_result:
                        result["links"] = query_result["link"]
                    if "media" in query_result:
                        result["media"] = query_result["media"]

                elif name != "text" and entity_id == query_result.get("uuid", ""):
                    result[name].append(query_result.get(name, ""))

    print("Updated results with data from query_results")


def format_final_results(results):
    """
    Concatenate field names and values from the results and format them for display.
    """
    final_results = []
    for index, result in enumerate(results):
        # Filter out control fields and empty lists
        filtered_result = {
            k: v
            for k, v in result.items()
            if k not in ["entity_id", "distance", "collection"] and v
        }

        # Concatenate field names and non-empty values, taking the first element if a list
        concatenated_values = " ".join(
            f"{k}: {next(iter(v), v) if isinstance(v, list) else v}"
            for k, v in filtered_result.items()
        )

        if concatenated_values.strip():
            formatted_result = f"Result {index + 1}: {concatenated_values}"
            final_results.append(formatted_result)
    print("Formatted final results")
    return "\n".join(final_results)


def save_to_file(data, filename):
    """Function to save data to a file, creating directory if it doesn't exist."""
    # Extract directory from the filename
    directory = os.path.dirname(filename)

    # Create the directory if it does not exist
    if not os.path.exists(directory):
        os.makedirs(directory)

    # Now, save the file
    with open(filename, "w") as file:
        file.write(str(data))


def populate_results(json_results_sorted, partition_names):
    collections = initialize_collections()
    entity_ids = extract_entity_ids(json_results_sorted)
    prepare_result_fields(json_results_sorted)
    query_results = query_collections(collections, entity_ids, partition_names)
    save_to_file(query_results, "data/query_results.txt")
    save_to_file(json_results_sorted, "data/update_results_with_query_data.txt")
    update_results_with_query_data(json_results_sorted, query_results)

    print("Populated results with sorted json results")

    # Example usage:
    # query_results = ... # Get the query results from the function

    # update_results_with_query_data = ... # Get the updated results from the function

    # json_results_sorted = ... # Assuming this is already defined and populated
    final_results = format_final_results(
        json_results_sorted[-10:]
    )  # Get the final formatted results
    save_to_file(final_results, "data/final_results.txt")

    return format_final_results(json_results_sorted[-10:])


def rank_partitions(prompt_embedding):
    # Convert the prompt to an embedding

    # Predict the class probabilities
    probabilities = SVM_MODEL.predict_proba([prompt_embedding])

    # Get the classes and their corresponding probabilities
    classes_and_probabilities = zip(LABEL_ENCODER.classes_, probabilities[0])

    # Sort the classes by probability
    ranked_classes = sorted(classes_and_probabilities, key=lambda x: x[1], reverse=True)

    # Extract the class names, ignoring the probabilities
    ranked_class_names = [item[0] for item in ranked_classes]

    print("Ranked partitions based on prompt_embedding")
    return ranked_class_names
