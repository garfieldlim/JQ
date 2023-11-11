from pymilvus import (
    connections,
    DataType,
    CollectionSchema,
    FieldSchema,
    Collection,
    Partition,
    utility,
)
from pymilvus import Milvus, DataType, Collection, MilvusException
import openai
import pandas as pd
import numpy as np
import re
import json
import torch.nn.functional as F
from torch import Tensor
from transformers import AutoTokenizer, AutoModel
import time
from tqdm import tqdm
from joblib import load
import uuid
from datetime import datetime
import copy
from flask import jsonify
from facebook_scraper import get_posts
import json
import os

openai.api_key = "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"
collections_list = [
    "text_collection",
    "author_collection",
    "title_collection",
    "contact_collection",
    "name_collection",
    "position_collection",
    "department_collection",
    "date_collection",
]
fields_list = [
    "text",
    "author",
    "title",
    "contact",
    "name",
    "position",
    "department",
    "date",
]
collections_dict = {
    "text_collection": [
        "uuid",
        "text_id",
        "text",
        "embeds",
        "media",
        "link",
        "partition_name",
    ],
    "author_collection": ["uuid", "author", "embeds", "partition_name"],
    "title_collection": ["uuid", "title", "embeds", "partition_name"],
    "date_collection": ["uuid", "date", "embeds", "partition_name"],
    "contact_collection": ["uuid", "contact", "embeds", "partition_name"],
    "department_collection": ["uuid", "department", "embeds", "partition_name"],
    "name_collection": ["uuid", "name", "embeds", "partition_name"],
    "position_collection": ["uuid", "position", "embeds", "partition_name"],
}

partitions = {
    "documents_partition": [
        "text_collection",
        "author_collection",
        "title_collection",
        "date_collection",
    ],
    "social_posts_partition": ["text_collection", "date_collection"],
    "contacts_partition": [
        "name_collection",
        "text_collection",
        "contact_collection",
        "department_collection",
    ],
    "people_partition": [
        "text_collection",
        "name_collection",
        "position_collection",
        "department_collection",
    ],
    "usjr_documents_partition": ["text_collection", "title_collection"],
    "scs_documents_partition": ["text_collection"],
    "religious_admin_people_partition": [
        "text_collection",
        "name_collection",
        "position_collection",
    ],
}
# Check if the connection already exists
if connections.has_connection("default"):
    connections.remove_connection("default")  # Disconnect if it exists

# Now, reconnect with your new configuration
connections.connect(alias="default", host="localhost", port="19530")


# fasttext_model = fasttext.load_model("C:/Users/Jillian/Desktop/crawl-300d-2M-subword.bin")
# fasttext_model = fasttext.load_model('/Users/garfieldgreglim/Library/Mobile Documents/com~apple~CloudDocs/Josenian-Query/Embedder/crawl-300d-2M-subword.bin')
def average_pool(last_hidden_states: Tensor, attention_mask: Tensor) -> Tensor:
    last_hidden = last_hidden_states.masked_fill(~attention_mask[..., None].bool(), 0.0)
    return last_hidden.sum(dim=1) / attention_mask.sum(dim=1)[..., None]


def get_embedding(text):
    # Load the tokenizer and model
    tokenizer = AutoTokenizer.from_pretrained("intfloat/e5-large-v2")
    model = AutoModel.from_pretrained("intfloat/e5-large-v2")

    # Prefix the text with 'query: '
    text = "query: " + text

    # Tokenize the input text
    inputs = tokenizer(
        text, max_length=512, padding=True, truncation=True, return_tensors="pt"
    )

    # Generate model outputs
    outputs = model(**inputs)

    # Average pool the last hidden states and apply the attention mask
    embeddings = average_pool(outputs.last_hidden_state, inputs["attention_mask"])

    # Normalize the embeddings
    embeddings = F.normalize(embeddings, p=2, dim=1)

    # Convert tensor to list
    embeddings_list = embeddings.tolist()

    return embeddings_list[0]


def remove_non_alphanumeric(text):
    return re.sub(r"[^a-zA-Z0-9\s]", "", text)


def vectorize_query(query):
    return get_embedding(query.lower())


def search_collections(vectors, partition_names):
    results_dict = {}
    search_params = {
        "metric_type": "L2",  # Distance metric, can be L2, IP (Inner Product), etc.
        "offset": 0,
    }
    for name in fields_list:
        try:
            if name == "text":
                collection = Collection(f"{name}_collection")
                collection.load()
                result = collection.search(
                    data=[vectors],
                    anns_field="embeds",
                    param=search_params,
                    limit=10,
                    partition_names=partition_names,
                    output_fields=["uuid", "text_id"],
                    consistency_level="Strong",
                )
                results_dict[name] = result
            else:
                collection = Collection(f"{name}_collection")
                collection.load()
                result = collection.search(
                    data=[vectors],
                    anns_field="embeds",
                    param=search_params,
                    limit=10,
                    partition_names=partition_names,
                    output_fields=["uuid"],
                    consistency_level="Strong",
                )
                results_dict[name] = result
        except MilvusException as e:
            if "partition name" in str(e) and "not found" in str(e):
                print(
                    f"Partition '{partition_names}' not found in collection '{name}', skipping..."
                )
                continue
            else:
                raise e  # if it's a different kind of MilvusException, we still want to raise it

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


def process_results(results_dict):
    json_results = {}

    for collection_name, result in results_dict.items():
        for query_hits in result:
            for hit in query_hits:
                if collection_name == "text":
                    id_field = "entity_id"
                    id_value = hit.entity.get("text_id")
                else:
                    id_field = "entity_id"
                    id_value = hit.id

                # Create the result dictionary
                result_dict = {
                    id_field: id_value,
                    "distance": hit.distance,
                    "collection": collection_name,
                }

                # If the id_value is already in the results and the new distance is greater, skip
                if (
                    id_value in json_results
                    and json_results[id_value]["distance"] < hit.distance
                ):
                    continue

                # Otherwise, update/insert the result
                json_results[id_value] = result_dict

            json_results_list = list(json_results.values())
            json_results_sorted = sorted(json_results_list, key=lambda x: x["distance"])

    return json_results_sorted


def populate_results(json_results_sorted, partition_names):
    # Load all collections beforehand
    collections = {name: Collection(f"{name}_collection") for name in fields_list}

    # Create a list of entity IDs for the query
    entity_ids = [result["entity_id"] for result in json_results_sorted]

    # Preparing an empty dictionary for each field in the results
    for result in json_results_sorted:
        for name in fields_list:
            result[name] = []

    final_results = []

    for name, collection in collections.items():
        try:
            # Prepare the query
            output_fields = []
            if name == "text":
                query_field = "text_id"
                output_fields = [
                    name,
                    "text_id",
                    "media",
                    "link",
                ]  # Include 'media' and 'link' here
            else:
                query_field = "uuid"
                output_fields = [name]

            query = f"{query_field} in {entity_ids}"

            query_results = collection.query(
                expr=query,
                offset=0,
                limit=len(entity_ids),
                partition_names=[partition_names],
                output_fields=output_fields,
                consistency_level="Strong",
            )

            # Append the results to the relevant fields in the results dictionary
            for query_result in query_results:
                for result in json_results_sorted:
                    if (
                        name == "text"
                        and result["entity_id"] == query_result["text_id"]
                    ):
                        # Append the 'media' and 'link' to the 'text' field
                        text_with_media_link = query_result[name]
                        if "media" in query_result:
                            text_with_media_link += " " + query_result["media"]
                        if "link" in query_result:
                            text_with_media_link += " " + query_result["link"]
                        result[name].append(text_with_media_link)
                    elif name != "text" and result["entity_id"] == query_result["uuid"]:
                        result[name].append(query_result[name])
        except Exception as e:
            print(f"Error with collection {name}: {str(e)}")

    for result in json_results_sorted:
        obj = {}
        for item in result:
            # If item is not 'entity_id', 'distance', or 'collection' and the item's value is not empty
            if item not in ["entity_id", "distance", "collection"] and result[item]:
                obj[item] = result[item]

        # Concatenate all values that aren't associated with the 'collection' key
        concatenated_values = " ".join(
            [
                str(v[0]) if isinstance(v, list) and v else str(v)
                for k, v in obj.items()
                if k != "collection"
            ]
        )

        if concatenated_values.strip():
            final_results.append(concatenated_values)

    # format final results with "Result {index}: " pattern
    formatted_results = [
        f"Result {index+1}:  {value}" for index, value in enumerate(final_results)
    ]
    return "\n".join(formatted_results)

    # def populate_results(json_results_sorted, partition_names):
    # Load all collections beforehand
    collections = {name: Collection(f"{name}_collection") for name in fields_list}

    # Create a list of entity IDs for the query
    entity_ids = [result["entity_id"] for result in json_results_sorted]

    # Preparing an empty dictionary for each field in the results
    for result in json_results_sorted:
        for name in fields_list:
            result[name] = []

    # Query for all relevant records at once
    for name, collection in collections.items():
        try:
            # Prepare the query
            output_fields = []
            if name == "text":
                query_field = "text_id"
                output_fields = [
                    name,
                    "text_id",
                    "media",
                    "link",
                ]  # Include 'media' and 'link' here
            else:
                query_field = "uuid"
                output_fields = [name]

            query = f"{query_field} in {entity_ids}"

            query_results = collection.query(
                expr=query,
                offset=0,
                limit=len(entity_ids),
                partition_names=[partition_names],
                output_fields=output_fields,
                consistency_level="Strong",
            )

            # Append the results to the relevant fields in the results dictionary
            for query_result in query_results:
                for result in json_results_sorted:
                    if (
                        name == "text"
                        and result["entity_id"] == query_result["text_id"]
                    ):
                        # Append the 'media' and 'link' to the 'text' field
                        text_with_media_link = query_result[name]
                        if "media" in query_result:
                            text_with_media_link += " " + query_result["media"]
                        if "link" in query_result:
                            text_with_media_link += " " + query_result["link"]
                        result[name].append(text_with_media_link)
                    elif name != "text" and result["entity_id"] == query_result["uuid"]:
                        result[name].append(query_result[name])

            final_results = []
            for result in json_results_sorted:
                obj = {}
                for item in result:
                    # If item is not 'entity_id', 'distance', or 'collection' and the item's value is not empty
                    if (
                        item not in ["entity_id", "distance", "collection"]
                        and result[item]
                    ):
                        obj[item] = result[item]
                # Concatenate all values that aren't associated with the 'collection' key
                concatenated_values = " ".join(
                    [str(v) for k, v in obj.items() if k != "collection"]
                )
                final_results.append(concatenated_values)
        except Exception as e:
            print(f"Error with collection {name}: {str(e)}")
    # format final results with "Result {index}: " pattern
    formatted_results = [
        f"Result {index+1}:  {value}" for index, value in enumerate(final_results)
    ]
    return "\n".join(formatted_results)

    # not it \/
    # def populate_results(json_results_sorted, partition_names):
    # Determine which collections we need based on the partition_names
    needed_collections = set()
    for partition in partition_names:
        needed_collections.update(partitions[partition])

    # Load only the required collections
    collections = {name: MockCollection(name) for name in needed_collections}

    # Create a list of entity IDs for the query
    entity_ids = [result["entity_id"] for result in json_results_sorted]

    # Preparing an empty dictionary for each field in the results
    for result in json_results_sorted:
        for name in fields_list:
            result[name] = []

    # Query for all relevant records at once
    for name, collection in collections.items():
        try:
            # Prepare the query
            output_fields = []
            if name == "text":
                query_field = "text_id"
                output_fields = [
                    name,
                    "text_id",
                    "media",
                    "link",
                ]  # Include 'media' and 'link' here
            else:
                query_field = "uuid"
                output_fields = [name]

            query_results = collection.query(
                expr=f"{query_field} in {entity_ids}",
                offset=0,
                limit=len(entity_ids),
                partition_names=partition_names,
                output_fields=output_fields,
                consistency_level="Strong",
            )

            # Append the results to the relevant fields in the results dictionary
            for query_result in query_results:
                for result in json_results_sorted:
                    if (
                        name == "text"
                        and result["entity_id"] == query_result["text_id"]
                    ):
                        # Append the 'media' and 'link' to the 'text' field
                        text_with_media_link = query_result[name]
                        if "media" in query_result:
                            text_with_media_link += " " + query_result["media"]
                        if "link" in query_result:
                            text_with_media_link += " " + query_result["link"]
                        result[name].append(text_with_media_link)
                    elif name != "text" and result["entity_id"] == query_result["uuid"]:
                        result[name].append(query_result[name])

            final_results = []
            for result in json_results_sorted:
                obj = {}
                for item in result:
                    # If item is not 'entity_id', 'distance', or 'collection' and the item's value is not empty
                    if (
                        item not in ["entity_id", "distance", "collection"]
                        and result[item]
                    ):
                        obj[item] = result[item]
                # Concatenate all values that aren't associated with the 'collection' key
                concatenated_values = " ".join(
                    [str(v) for k, v in obj.items() if k != "collection"]
                )
                final_results.append(concatenated_values)
        except Exception as e:
            print(f"Error with collection {name}: {str(e)}")
    # format final results with "Result {index}: " pattern
    formatted_results = [
        f"Result {index+1}:  {value}" for index, value in enumerate(final_results)
    ]
    return "\n".join(formatted_results)


def generate_response(prompt, string_json):
    # Format the input as per the desired conversation format
    conversation = [
        {
            "role": "system",
            "content": """You are Josenian Quiri. University of San Jose- Recoletos' general knowledge base assistant. Refer to yourself as JQ. If there are links, give the link as well.""",
        },
        {"role": "user", "content": prompt},
        {
            "role": "system",
            "content": f"Here is the returned data from your knowledge base (note: select only the correct answer): \n{string_json}]",
        },
        {"role": "user", "content": ""},
    ]

    # Convert the conversation to a string
    conversation_str = "".join(
        [f'{item["role"]}: {item["content"]}\n' for item in conversation]
    )

    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=conversation,
        temperature=1,
        max_tokens=1000,
        top_p=1,
        frequency_penalty=0,
        presence_penalty=0,
    )

    # Extract the generated response from the API's response
    generated_text = response["choices"][0]["message"]["content"]

    # Return the response
    return generated_text


def ranking_partitions(vectors):
    return [
        "people_partition",
        "documents_partition",
        "social_posts_partition",
        "contacts_partition",
    ]


svm_model = load("jq_admin/lib/flask/models/svm_model.joblib")
label_encoder = load("jq_admin/lib/flask/models/label_encoder.joblib")


def rank_partitions(prompt_embedding):
    # Convert the prompt to an embedding

    # Predict the class probabilities
    probabilities = svm_model.predict_proba([prompt_embedding])

    # Get the classes and their corresponding probabilities
    classes_and_probabilities = zip(label_encoder.classes_, probabilities[0])

    # Sort the classes by probability
    ranked_classes = sorted(classes_and_probabilities, key=lambda x: x[1], reverse=True)

    # Extract the class names, ignoring the probabilities
    ranked_class_names = [item[0] for item in ranked_classes]

    return ranked_class_names


def refactor_date(input_date):
    # Parse the input date using datetime.datetime.strptime
    parsed_date = datetime.strptime(input_date, "%a, %d %b %Y %H:%M:%S %Z")

    # Format the date in the desired format
    formatted_date = parsed_date.strftime("%Y-%m-%d %B %d %Y")
    return formatted_date


def process_object(obj):
    # Create a 'uuid' attribute
    obj["link"] = obj.pop("url")
    obj.pop("schema")
    obj["partition_name"] = "social_posts_partition"
    obj["uuid"] = str(uuid.uuid4())
    obj["date"] = obj.pop("time")
    obj["date"] = refactor_date(
        obj["date"]
    )  # Assuming refactor_date function is defined elsewhere
    # Create 'embeds' attribute by appending all values in the object
    obj["embeds"] = [
        value for key, value in obj.items() if key != "embeds" and key != "text"
    ]
    obj["text_id"] = obj["uuid"]  # Adding 'text_id' attribute
    # Check if 'embeds' has more than 100 words
    total_words = sum(len(str(value).split()) for value in obj["embeds"])

    obj_list = []
    if total_words > 100:
        # Split into equal objects
        n_parts = total_words // 100
        words_per_part = total_words // n_parts
        words_processed = 0

        for i in range(n_parts):
            chunk_obj = copy.deepcopy(obj)
            words_in_chunk = obj["text"][
                words_processed : words_processed + words_per_part
            ]
            chunk_obj["embeds"] = words_in_chunk
            chunk_obj["uuid"] = str(uuid.uuid4())
            chunk_obj["text_id"] = obj["uuid"]
            obj_list.append(chunk_obj)
            words_processed += len(words_in_chunk.split())

        # Handle remaining words if they don't evenly divide
        remaining_words = obj["text"][words_processed:]
        if remaining_words:
            chunk_obj = copy.deepcopy(obj)
            chunk_obj["embeds"] = remaining_words
            chunk_obj["uuid"] = str(uuid.uuid4())
            chunk_obj["text_id"] = obj["uuid"]
            obj_list.append(chunk_obj)
    else:
        obj_list.append(obj)
    text_collection_keys = [
        "uuid",
        "text_id",
        "text",
        "embeds",
        "media",
        "link",
        "partition_name",
    ]
    date_collection_keys = ["uuid", "date", "embeds", "partition_name"]

    text_objects = []
    date_objects = []

    for count, obj in enumerate(obj_list, 1):
        text_object = {key: obj.get(key, None) for key in text_collection_keys}
        date_object = {key: obj.get(key, None) for key in date_collection_keys}
        text_embeds_str = " ".join(map(str, text_object["embeds"]))
        date_embeds_str = " ".join(map(str, date_object["embeds"]))
        text_object["embeds"] = get_embedding(
            text_embeds_str
        )  # Assuming get_embedding function is defined elsewhere
        date_object["embeds"] = get_embedding(
            date_embeds_str
        )  # Assuming get_embedding function is defined elsewhere
        text_objects.append(text_object)
        date_objects.append(date_object)

        print(f"COUNT {count}-")
        print(f"OBJ[{count}] text_object:", text_object)
        print(f"OBJ[{count}] date_object:", date_object)
        print("\n")
    for obj in text_objects:
        for attribute in obj:
            if obj[attribute] is None:
                obj[attribute] = ""
    collection = Collection(
        "text_collection"
    )  # Assuming Collection is defined elsewhere
    print(collection.insert(text_objects, "social_posts_partition"))
    collection = Collection("date_collection")  # Fixed collection name
    print(
        collection.insert(date_objects, "social_posts_partition")
    )  # Fixed variable name

    return obj_list

def get_facebook_posts():
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }

    existing_posts = []
    existing_ids = set()

    posts_json_path = 'C:/Users/user/Documents/3rd year/Summer/Thesis 1/JQ/posts.json'

    # Attempt to read existing posts from the JSON file
    if os.path.isfile(posts_json_path):
        try:
            with open(posts_json_path, 'r', encoding='utf-8') as f:
                existing_posts = json.load(f)
                existing_ids = {post['post_id'] for post in existing_posts}
        except json.JSONDecodeError as e:
            print(f"Error reading {posts_json_path}: {e}")
            # Handle the corrupted JSON file (e.g., rename it for backup)
            corrupted_path = posts_json_path + ".corrupted"
            os.rename(posts_json_path, corrupted_path)
            print(f"Renamed corrupted file to {corrupted_path}")

    posts = []
    try:
        for i, post in enumerate(get_posts('usjrforward', cookies="C:/Users/user/Documents/3rd year/Summer/Thesis 1/JQ/jq_admin/lib/flask/cookies.json", pages=2, options={"headers": headers}), start=1):
            if post['post_id'] in existing_ids:
                print(f"Skipping duplicate post: {post['post_id']}")
                continue
            print(f"Count {i}: {post['text']}")
            posts.append(post)
            existing_ids.add(post['post_id'])
            time.sleep(1)
    except Exception as e:
        print(f"Error: {e}")

    # Append new posts to existing posts
    existing_posts.extend(posts)

    # Save the combined list of posts into the JSON file
    with open('posts.json', 'w', encoding='utf-8') as f:
        json.dump(existing_posts, f, cls=DateTimeEncoder, indent=4)

    return json.dumps(existing_posts, cls=DateTimeEncoder, indent=4)

def update_posts_json():
    posts_json_path = 'C:/Users/user/Documents/3rd year/Summer/Thesis 1/JQ/posts.json'  # Assuming posts.json is in the current working directory

    # If posts.json exists, delete it and write the new posts
    if os.path.isfile(posts_json_path):
        os.remove(posts_json_path)

    # Fetch new posts
    new_posts_json  = get_facebook_posts()    
    
    # Check if there are new posts
    if new_posts_json:
        new_posts = json.loads(new_posts_json)  # Parse the JSON string into a Python list
        # Write the new posts
        with open(posts_json_path, 'w', encoding='utf-8') as file:
            json.dump(new_posts, file, cls=DateTimeEncoder, indent=4)
        print("posts.json has been updated with the latest posts.")
    else:
        print("No posts were fetched.")
    #     # If posts.json exists, delete existing posts
    #     if os.path.isfile(posts_json_path):
    #         os.remove(posts_json_path)
    #         # with open(posts_json_path, 'r') as file:
    #         #     existing_posts = json.load(file)

    #         # If new posts are different from existing posts, update posts.json
    #         # if new_posts != existing_posts:
    #         #     os.remove(posts_json_path)
    #         #     with open(posts_json_path, 'w') as file:
    #         #         json.dump(new_posts, file)
    #         #     print("New posts detected and posts.json has been updated.")
    #         # else:
    #         #     print("No new posts were found. posts.json remains unchanged.")
    #     else:
    #         # If posts.json does not exist, create it with the new posts
    #         with open(posts_json_path, 'w') as file:
    #             json.dump(new_posts, file)
    #         print("posts.json did not exist and has been created with the latest posts.")
    # else:
    #     print("No posts were fetched.")


def question_answer():
    while True:
        try:
            prompt = input("You: ")
            if not prompt:
                print("No input provided. Try again.")
                continue
            vectors = vectorize_query(prompt)
            if vectors is None:
                print("No vectors returned. Check your vectorize_query function.")
                continue
            ranked_partitions = ranking_partitions(vectors)
            if ranked_partitions is None:
                print(
                    "No ranked_partitions returned. Check your ranking_partitions function."
                )
                continue
            print(f"Ranked partitions: {ranked_partitions}")
            partition = 0
            correct = 0
            while correct != 1:
                results_dict = search_collections(
                    vectors, [ranked_partitions[partition]]
                )
                if results_dict is None:
                    print(
                        "No results returned. Check your search_collections function."
                    )
                    break
                json_results_sorted = process_results(results_dict)
                if json_results_sorted is None:
                    print(
                        "No sorted results returned. Check your process_results function."
                    )
                    break
                final_results = populate_results(
                    json_results_sorted, ranked_partitions[partition]
                )
                if final_results is None:
                    print(
                        "No final results returned. Check your populate_results function."
                    )
                    break
                string_json = json.dumps(final_results)
                display(string_json)
                generated_text = generate_response(prompt, string_json)
                if generated_text is None:
                    print(
                        "No response generated. Check your generate_response function."
                    )
                    break
                print(f"JQ: {generated_text}")
                correct = input("Is the answer correct? 1-Y, 0-N: ")
                if correct not in ["0", "1"]:
                    print("Invalid input. Try again.")
                elif partition <= 3:
                    partition = partition + 1
                else:
                    partition = 0
        except Exception as e:
            print(f"An error occurred: {e}")


# Assuming you have already imported all necessary modules and set up the environment

# Define a dictionary that maps each collection to its desired field
desired_fields = {
    "text_collection": "text",
    "title_collection": "title",
    "author_collection": "author",
    "contact_collection": "contact",
    "department_collection": "department",
    "name_collection": "name",
    "position_collection": "position",
    "date_collection": "date",
}

table_fields = {
    "documents_partition": [
        "text",
        "author",
        "title",
        "date",
    ],
    "social_posts_partition": ["text", "date"],
    "contacts_partition": [
        "name",
        "text",
        "contact",
        "department",
    ],
    "people_partition": [
        "text",
        "name",
        "position",
        "department",
    ],
}


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
