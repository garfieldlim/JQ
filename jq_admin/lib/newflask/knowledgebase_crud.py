import uuid
import copy
from pymilvus import (
    Collection,
)
from embeddings import vectorize_query

from utils.utilities import refactor_date

from dictionary import desired_fields, table_fields, collections_dict


def process_object(obj):

    # Rename 'url' attribute to 'link' if it exists
    obj["link"] = obj.pop(
        "url", None
    )  # Use pop with a default of None to avoid KeyError

    # Remove 'schema' attribute, if it exists, using pop with a default value to avoid KeyError
    obj.pop("schema", None)

    # Set 'media' to an empty string if it doesn't exist to match the expected schema
    obj.setdefault(
        "media", ""
    )  # Using an empty string instead of None based on the error suggestion

    # Generate a new UUID for 'uuid' and 'text_id'
    new_uuid = str(uuid.uuid4())
    obj["uuid"] = new_uuid
    obj["text_id"] = new_uuid

    # Refactor 'time' attribute to 'date', if it exists
    if "time" in obj:
        obj["date"] = refactor_date(obj.pop("time"))

    # Set 'partition_name'
    obj["partition_name"] = "social_posts_partition"

    # Prepare objects for text and date collections
    text_collection_obj = {
        key: obj.get(key)
        for key in [
            "uuid",
            "text_id",
            "text",
            "embeds",
            "media",
            "link",
            "partition_name",
        ]
    }
    date_collection_obj = {
        key: obj.get(key) for key in ["uuid", "date", "embeds", "partition_name"]
    }

    # Vectorize 'embeds' if necessary
    text_collection_obj["embeds"] = vectorize_query(
        text_collection_obj.get("text", "").lower()
    )
    print(text_collection_obj["embeds"])
    date_collection_obj["embeds"] = vectorize_query(
        date_collection_obj.get("date", "").lower()
    )

    # Assuming Collection is correctly defined and initialized elsewhere
    text_collection = Collection("text_collection")
    date_collection = Collection("date_collection")

    # Perform insertions into collections
    print(
        text_collection.insert(
            [text_collection_obj], partition_name="social_posts_partition"
        )
    )
    print(
        date_collection.insert(
            [date_collection_obj], partition_name="social_posts_partition"
        )
    )

    # Print upsert confirmation
    print(f"Upserted: {obj['partition_name']}, {obj['uuid']}, {obj['text_id']}")


def process_object_documents(obj):

    # Rename 'url' attribute to 'link' if it exists
    obj["link"] = obj.pop(
        "links", None
    )  # Use pop with a default of None to avoid KeyError

    # Generate a new UUID for 'uuid' and 'text_id'
    new_uuid = str(uuid.uuid4())
    obj["uuid"] = new_uuid
    obj.setdefault(
        "media", ""
    )  # Using an empty string instead of None based on the error suggestion

    obj["text_id"] = new_uuid

    # Refactor 'time' attribute to 'date', if it exists

    # Prepare objects for text and date collections
    text_collection_obj = {
        key: obj.get(key)
        for key in [
            "uuid",
            "text_id",
            "text",
            "embeds",
            "media",
            "link",
            "partition_name",
        ]
    }
    date_collection_obj = {
        key: obj.get(key) for key in ["uuid", "date", "embeds", "partition_name"]
    }

    author_collection_obj = {
        key: obj.get(key) for key in ["uuid", "author", "embeds", "partition_name"]
    }
    title_collection_obj = {
        key: obj.get(key) for key in ["uuid", "title", "embeds", "partition_name"]
    }

    # Vectorize 'embeds' if necessary
    text_collection_obj["embeds"] = vectorize_query(
        text_collection_obj.get("text", "").lower()
    )
    print(text_collection_obj["embeds"])
    date_collection_obj["embeds"] = vectorize_query(
        date_collection_obj.get("date", "").lower()
    )
    author_collection_obj["embeds"] = vectorize_query(
        author_collection_obj.get("author", "").lower()
    )
    title_collection_obj["embeds"] = vectorize_query(
        title_collection_obj.get("title", "").lower()
    )

    # Assuming Collection is correctly defined and initialized elsewhere
    text_collection = Collection("text_collection")
    date_collection = Collection("date_collection")
    author_collection = Collection("author_collection")
    title_collection = Collection("title_collection")

    # Perform insertions into collections
    print(
        text_collection.insert(
            [text_collection_obj], partition_name="documents_partition"
        )
    )
    print(
        date_collection.insert(
            [date_collection_obj], partition_name="documents_partition"
        )
    )
    print(
        author_collection.insert(
            [author_collection_obj], partition_name="documents_partition"
        )
    )
    print(
        title_collection.insert(
            [title_collection_obj], partition_name="documents_partition"
        )
    )
    # Print upsert confirmation
    print(f"Upserted: {obj['partition_name']}, {obj['uuid']}, {obj['text_id']}")


def process_object_people(obj):

    # Rename 'url' attribute to 'link' if it exists
    obj["link"] = obj.pop(
        "links", None
    )  # Use pop with a default of None to avoid KeyError

    # Generate a new UUID for 'uuid' and 'text_id'
    new_uuid = str(uuid.uuid4())
    obj["uuid"] = new_uuid
    obj.setdefault(
        "media", ""
    )  # Using an empty string instead of None based on the error suggestion

    obj["text_id"] = new_uuid

    # Refactor 'time' attribute to 'date', if it exists

    # Prepare objects for text and date collections
    text_collection_obj = {
        key: obj.get(key)
        for key in [
            "uuid",
            "text_id",
            "text",
            "embeds",
            "media",
            "link",
            "partition_name",
        ]
    }
    department_collection_obj = {
        key: obj.get(key) for key in ["uuid", "department", "embeds", "partition_name"]
    }
    name_collection_obj = {
        key: obj.get(key) for key in ["uuid", "name", "embeds", "partition_name"]
    }
    position_collection_obj = {
        key: obj.get(key) for key in ["uuid", "position", "embeds", "partition_name"]
    }

    # Vectorize 'embeds' if necessary
    text_collection_obj["embeds"] = vectorize_query(
        text_collection_obj.get("text", "").lower()
    )
    print(text_collection_obj["embeds"])
    department_collection_obj["embeds"] = vectorize_query(
        department_collection_obj.get("department", "").lower()
    )
    name_collection_obj["embeds"] = vectorize_query(
        name_collection_obj.get("name", "").lower()
    )
    position_collection_obj["embeds"] = vectorize_query(
        position_collection_obj.get("position", "").lower()
    )

    # Assuming Collection is correctly defined and initialized elsewhere
    text_collection = Collection("text_collection")
    name_collection = Collection("name_collection")
    department_collection = Collection("department_collection")
    position_collection = Collection("position_collection")

    # Perform insertions into collections
    print(
        text_collection.insert([text_collection_obj], partition_name="people_partition")
    )
    print(
        name_collection.insert([name_collection_obj], partition_name="people_partition")
    )
    print(
        department_collection.insert(
            [department_collection_obj], partition_name="people_partition"
        )
    )
    print(
        position_collection.insert(
            [position_collection_obj], partition_name="people_partition"
        )
    )
    # Print upsert confirmation
    print(f"Upserted: {obj['partition_name']}, {obj['uuid']}, {obj['text_id']}")


# Define a function to query all items in a collection based on partition_name
def query_collection_by_partition(collection_name, partition_name):
    collection = Collection(collection_name)
    collection.load()
    # Fetch text_id for text_collection and uuid for other collections
    id_field = "text_id" if collection_name == "text_collection" else "uuid"
    res = collection.query(
        expr=f"partition_name == '{partition_name}'",
        output_fields=[desired_fields[collection_name], id_field],
    )
    return res


def combine_results_by_uuid(partition_name, search_query=None):
    all_items = []

    # Phase 1: Collect all items across collections
    for collection_name, fields in collections_dict.items():
        results = query_collection_by_partition(collection_name, partition_name)
        for item in results:
            item["_source_collection"] = (
                collection_name  # Track the source collection for reference
            )
            all_items.append(item)

    combined_results = {}

    # Phase 2: Combine items based on unique IDs without applying search criteria
    for item in all_items:
        collection_name = item["_source_collection"]
        id_key = "text_id" if collection_name == "text_collection" else "uuid"
        unique_id = item[id_key]

        if unique_id not in combined_results:
            combined_results[unique_id] = {
                field: []  # Initialize fields as lists to accumulate values
                for collection in collections_dict.values()
                for field in collection
            }

        for field in collections_dict[collection_name]:
            item_value = item.get(field, "").strip()
            if item_value:
                if item_value not in combined_results[unique_id][field]:
                    combined_results[unique_id][field].append(item_value)

    # Phase 3: Apply search criteria after combining and prepare final results
    final_results = {}
    for unique_id, fields in combined_results.items():
        combined_item = {field: ", ".join(values) for field, values in fields.items()}

        # Check if the combined item matches the search criteria
        if search_query:
            if not matches_search_criteria(
                combined_item, search_query, sum(collections_dict.values(), [])
            ):
                continue  # Skip items that do not match the search criteria

        final_results[unique_id] = combined_item

    return final_results


def matches_search_criteria(item, search_query, fields_list):
    search_query = search_query.lower()
    for field in fields_list:
        field_value = item.get(field, "")
        if search_query in field_value.lower():
            return True
    return False


def matches_search_criteria(item, search_query, fields_list):
    search_query = search_query.lower()
    for field in fields_list:
        if field in item and search_query in item[field].lower():
            return True
    return False


def create_table(combined_data, partition_name):
    table = {}
    for i, (uuid, data) in enumerate(combined_data.items()):
        table[i] = {"uuid": uuid}
        for fieldname in table_fields[partition_name]:
            table[i][fieldname] = data.get(
                fieldname, ""
            )  # Use get() to handle missing fields
    return table


def get_uuids_from_text_id(collection_name, text_id):
    # Load the collection
    collection = Collection(collection_name)
    collection.load()

    # Assuming 'text_id' is a searchable field in your schema
    # Construct a search parameter or a query to find matching items
    search_params = {"metric_type": "L2", "params": {"nprobe": 16}}
    # Replace the below query with an appropriate query mechanism to find items by text_id
    # This is a placeholder and will need to be replaced with actual search or query logic
    query = f"text_id == '{text_id}'"
    results = collection.search(query, search_params)

    # Extract UUIDs from the search results
    uuids = [
        result.id for result in results
    ]  # Adjust based on how your results are structured

    return uuids


def delete_by_text_id(text_id, partition_name):
    # Initialize Milvus collection for the text collection
    text_collection = Collection("text_collection")
    text_collection.load()

    # Query to find items by text_id in the text collection
    query = f"text_id == '{text_id}'"
    try:
        query_results = text_collection.query(
            expr=query,
            partition_names=[partition_name],
            output_fields=["uuid"],  # Assuming 'uuid' is the field you want to retrieve
            consistency_level="Strong",
        )
        # Extract UUIDs from query results
        uuids = [item["uuid"] for item in query_results]
        print(f"UUIDs found for text_id {text_id}: {uuids}")
    except Exception as e:
        print(f"Error querying text_collection for text_id {text_id}: {e}")
        return

    # Proceed to delete items based on UUIDs in all relevant collections
    for collection_name in collections_dict.keys():
        collection = Collection(collection_name)
        collection.load()
        for uuid in uuids:
            expr = f"uuid in ['{uuid}']"  # Deletion query based on UUID
            try:
                result = collection.delete(
                    expr=expr,
                    partition_name=partition_name,  # Specify if partitioning is used
                )
                print(
                    f"Deleted items with UUID {uuid} from {collection_name}, delete count: {result.delete_count}"
                )
            except Exception as e:
                print(
                    f"Error deleting UUID {uuid} from collection {collection_name}: {e}"
                )
