from config import LABEL_ENCODER, SVM_MODEL
from dictionary import fields_list
from pymilvus import (
    MilvusException,
    DataType,
    Collection,
)
import json


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
    Update the results with data from the query results.
    """
    for name, collection_results in query_results.items():
        for query_result in collection_results:
            for result in results:
                entity_id = result["entity_id"]
                if name == "text" and entity_id == query_result["text_id"]:
                    result[name].append(query_result.get(name, ""))
                elif name != "text" and entity_id == query_result.get("uuid", ""):
                    result[name].append(query_result.get(name, ""))
    return results


def format_final_results(results):
    """
    Concatenate values from the results, sort by distance, and format them for display.
    """
    # save results to /Users/garfieldgreglim/Desktop/json_test/initial_results
    json_file_path = "/Users/garfieldgreglim/Desktop/json_test/initial_results.json"
    try:
        with open(json_file_path, "w") as file:
            json.dump(results, file)
        print(f"Initial results saved to {json_file_path}")
    except IOError as e:
        print(f"Failed to save initial results: {e}")
    # Sort the results by the 'distance' field
    sorted_results = sorted(results, key=lambda x: x.get("distance", float("inf")))

    final_results = []
    for index, result in enumerate(sorted_results):
        # Filter out control fields and empty lists
        filtered_result = {
            k: v
            for k, v in result.items()
            if k not in ["entity_id", "distance", "collection"] and v
        }

        # Concatenate non-empty values, taking the first element if a list
        concatenated_values = " ".join(
            str(next(iter(v), v)) if isinstance(v, list) else str(v)
            for v in filtered_result.values()
        )

        if concatenated_values.strip():
            formatted_result = f"Result {index + 1}: {concatenated_values}"
            final_results.append(formatted_result)

    # Ensure there's at least one result before saving to JSON
    if final_results:
        print("Formatted final results")
        json_file_path = (
            "/Users/garfieldgreglim/Desktop/json_test/formatted_results.json"
        )
        try:
            with open(json_file_path, "w") as file:
                json.dump(final_results, file)
            print(f"Formatted results saved to {json_file_path}")
        except IOError as e:
            print(f"Failed to save formatted results: {e}")
    # final results takes the first 10 results
    final_results = final_results[:10]
    return final_results


def populate_results(json_results_sorted, partition_names):
    collections = initialize_collections()
    entity_ids = extract_entity_ids(json_results_sorted)
    prepare_result_fields(json_results_sorted)
    query_results = query_collections(collections, entity_ids, partition_names)
    json_results_sorted = update_results_with_query_data(
        json_results_sorted, query_results
    )
    json_results_sorted_file_path = (
        "/Users/garfieldgreglim/Desktop/json_test/results.json"
    )

    # Save 'results' as a JSON file
    try:
        with open(json_results_sorted_file_path, "w") as file:
            json.dump(json_results_sorted, file)
        print(f"Results saved to {json_results_sorted_file_path}")
    except IOError as e:
        print(f"Failed to save results: {e}")

    print("Populated results with sorted json results")
    return format_final_results(json_results_sorted)


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
