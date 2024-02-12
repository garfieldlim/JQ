import uuid
import copy
from pymilvus import (
    Collection,
)
from embeddings import vectorize_query

from utils.utilities import refactor_date

from dictionary import desired_fields, partitions, table_fields


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


# def process_object(obj):
#     # Create a 'uuid' attribute
#  # Rename 'url' attribute to 'link'
#     if "url" in obj:
#         obj["link"] = obj.pop("url")

#     # Remove 'schema' attribute, if it exists
#     obj.pop("schema", None)  # Use None as the default to avoid KeyError if 'schema' does not exist

#     # Add or update 'partition_name'
#     obj["partition_name"] = "social_posts_partition"

#     # Generate a new UUID and assign it to both 'uuid' and 'text_id'
#     new_uuid = str(uuid.uuid4())
#     obj["uuid"] = new_uuid
#     obj["text_id"] = obj["uuid"]

#     # Refactor 'time' attribute to 'date', if it exists, and apply the refactoring
#     if "time" in obj:
#         obj["date"] = refactor_date(obj.pop("time"))


#     # For every attribute in object print attribute_name: content
#     for key, value in obj.items():


#     # Check if 'embeds' has more than 100 words
#     total_words = sum(len(str(value).split()) for value in obj["embeds"])
#     print("text_id:", obj["text_id"])
#     print("uuid:", obj["uuid"])

#     obj_list = []
#     if total_words > 100:
#         # Split into equal objects
#         n_parts = total_words // 100
#         chunk_size = len(obj["text"]) // n_parts
#         # return

#         for i in range(n_parts):
#             chunk_obj = copy.deepcopy(obj)
#             words_in_chunk = obj["text"][
#                 words_processed : words_processed + words_per_part
#             ]
#             chunk_obj["embeds"] = words_in_chunk
#             chunk_obj["uuid"] = str(uuid.uuid4())
#             chunk_obj["text_id"] = obj["uuid"]
#             obj_list.append(chunk_obj)
#             words_processed += len(words_in_chunk.split())

#         # Handle remaining words if they don't evenly divide
#         remaining_words = obj["text"][words_processed:]
#         if remaining_words:
#             chunk_obj = copy.deepcopy(obj)
#             chunk_obj["embeds"] = remaining_words
#             chunk_obj["uuid"] = str(uuid.uuid4())
#             chunk_obj["text_id"] = obj["uuid"]
#             obj_list.append(chunk_obj)
#     else:
#         obj_list.append(obj)
#     text_collection_keys = [
#         "uuid",
#         "text_id",
#         "text",
#         "embeds",
#         "media",
#         "link",
#         "partition_name",
#     ]
#     date_collection_keys = ["uuid", "date", "embeds", "partition_name"]

#     text_objects = []
#     date_objects = []

#     for count, obj in enumerate(obj_list, 1):
#         text_object = {key: obj.get(key, None) for key in text_collection_keys}
#         date_object = {key: obj.get(key, None) for key in date_collection_keys}
#         text_embeds_str = " ".join(map(str, text_object["embeds"]))
#         date_embeds_str = " ".join(map(str, date_object["embeds"]))
#         text_embeds_str = text_embeds_str.lower()
#         date_embeds_str = date_embeds_str.lower()
#         text_object["embeds"] = vectorize_query(
#             text_embeds_str
#         )  # Assuming get_embedding function is defined elsewhere
#         date_object["embeds"] = vectorize_query(
#             date_embeds_str
#         )  # Assuming get_embedding function is defined elsewhere
#         text_objects.append(text_object)
#         date_objects.append(date_object)

#         print(f"COUNT {count}-")
#         print(len(text_object["embeds"]))
#         print(f"OBJ[{count}] text_object:", text_object)
#         print(f"OBJ[{count}] date_object:", date_object)
#         print("\n")
#     for obj in text_objects:
#         for attribute in obj:
#             if obj[attribute] is None:
#                 obj[attribute] = ""
#     collection = Collection(
#         "text_collection"
#     )  # Assuming Collection is defined elsewhere

#     print(collection.insert(text_objects, "social_posts_partition"))
#     collection = Collection("date_collection")  # Fixed collection name
#     print(
#         collection.insert(date_objects, "social_posts_partition")
#     )  # Fixed variable name
#     # print Upserted: partition_name, uuid, text_id
#     print(f"Upserted: {obj['partition_name']}, {obj['uuid']}, {obj['text_id']}")
#     return obj_list


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
