import uuid
import copy
from pymilvus import (
    Collection,
)
from embeddings import vectorize_query

from utils.utilities import refactor_date

from dictionary import desired_fields, partitions, table_fields


def initialize_object_attributes(obj):
    obj["link"] = obj.pop("url")
    obj.pop("schema")
    obj["partition_name"] = "social_posts_partition"
    obj["uuid"] = str(uuid.uuid4())
    obj["date"] = refactor_date(obj.pop("time"))
    obj["embeds"] = [
        value for key, value in obj.items() if key not in ["embeds", "text"]
    ]
    obj["text_id"] = obj["uuid"]
    return obj


def split_text_chunks(obj, max_words=100):
    total_words = sum(len(str(value).split()) for value in obj["embeds"])
    if total_words <= max_words:
        return [obj]

    obj_list = []
    words = obj["text"].split()
    for i in range(0, total_words, max_words):
        chunk_obj = copy.deepcopy(obj)
        chunk_obj["embeds"] = " ".join(words[i : i + max_words])
        chunk_obj["uuid"] = str(uuid.uuid4())
        obj_list.append(chunk_obj)

    return obj_list


def create_collection_objects(obj_list):
    text_objects, date_objects = [], []
    for obj in obj_list:
        text_object = {
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
        date_object = {
            key: obj.get(key) for key in ["uuid", "date", "embeds", "partition_name"]
        }

        text_object["embeds"] = vectorize_query(text_object["embeds"])
        date_object["embeds"] = vectorize_query(date_object["embeds"])

        text_objects.append(text_object)
        date_objects.append(date_object)
    return text_objects, date_objects


def insert_into_collections(text_objects, date_objects):
    text_collection = Collection("text_collection")
    date_collection = Collection("date_collection")

    text_collection.insert(text_objects, "social_posts_partition")
    date_collection.insert(date_objects, "social_posts_partition")


def print_objects(objects):
    for count, obj in enumerate(objects, 1):
        print(f"COUNT {count}-")
        print(
            f"OBJ[{count}] text_object:", obj[0]
        )  # Assuming obj is a tuple (text_object, date_object)
        print(f"OBJ[{count}] date_object:", obj[1])
        print("\n")


def process_object(obj):
    obj = initialize_object_attributes(obj)
    obj_list = split_text_chunks(obj)
    text_objects, date_objects = create_collection_objects(obj_list)
    insert_into_collections(text_objects, date_objects)
    print_objects(zip(text_objects, date_objects))

    return obj_list


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


# Define a function to combine results by uuid (or text_id for text_collection)
def combine_results_by_uuid(partition_name):
    combined_results = {}

    # Loop through each collection in the given partition
    for collection_name in partitions[partition_name]:
        results = query_collection_by_partition(collection_name, partition_name)

        # Loop through each result and store/combine in the combined_results dictionary
        for item in results:
            # Use text_id for text_collection and uuid for other collections
            id_key = "text_id" if collection_name == "text_collection" else "uuid"
            unique_id = item[id_key]
            field_name = desired_fields[collection_name]

            # Initialize the unique_id entry with all desired fields set to empty strings
            if unique_id not in combined_results:
                combined_results[unique_id] = {
                    field: "" for field in table_fields[partition_name]
                }

            # Append the value if it already exists for the unique_id
            if (
                field_name in combined_results[unique_id]
                and combined_results[unique_id][field_name]
            ):
                combined_results[unique_id][field_name] += ", " + item[field_name]
            else:
                combined_results[unique_id][field_name] = item[field_name]

    return combined_results


def create_table(combined_data, partition_name):
    table = {}
    for i, (uuid, data) in enumerate(combined_data.items()):
        table[i] = {"uuid": uuid}
        for fieldname in table_fields[partition_name]:
            table[i][fieldname] = data.get(
                fieldname, ""
            )  # Use get() to handle missing fields
    return table
