from pymilvus import connections, DataType, CollectionSchema, FieldSchema, Collection, Partition, utility
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
import fasttext
import joblib
openai.api_key = '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'
collections_list = [
    'text_collection',
    'author_collection',
    'title_collection',
    'contact_collection',
    'name_collection',
    'position_collection',
    'department_collection',
    'date_collection',
]
fields_list = [
    'text',
    'author',
    'title',
    'contact',
    'name',
    'position',
    'department',
    'date',
]
collections_dict = {
    "text_collection": ["uuid", "text_id", "text", "embeds", "media", "link", "partition_name"],
    "author_collection": ["uuid", "author", "embeds", "partition_name"],
    "title_collection": ["uuid", "title", "embeds", "partition_name"],
    "date_collection": ["uuid", "date", "embeds", "partition_name"],
    "contact_collection": ["uuid", "contact", "embeds", "partition_name"],
    "department_collection": ["uuid", "department", "embeds", "partition_name"],
    "name_collection": ["uuid", "name", "embeds", "partition_name"],
    "position_collection": ["uuid", "position", "embeds", "partition_name"]
}

partitions = {
    "documents_partition": ["text_collection", "author_collection", "title_collection", "date_collection"],
    "social_posts_partition": ["text_collection", "date_collection"],
    "contacts_partition": ["name_collection", "text_collection", "contact_collection", "department_collection"],
    "people_partition": ["text_collection","name_collection","position_collection","department_collection"],
    "usjr_documents_partition": ["text_collection", "title_collection"],
    "scs_documents_partition" : ["text_collection"],
    "religious_admin_people_partition": ["text_collection","name_collection","position_collection"],
}
# Check if the connection already exists
if connections.has_connection('default'):
    connections.remove_connection('default')  # Disconnect if it exists

# Now, reconnect with your new configuration
connections.connect(alias='default', host='localhost', port='19530')
fasttext_model = fasttext.load_model("C:/Users/Jillian/Desktop/crawl-300d-2M-subword.bin")
def get_embedding(text, embedding_type):
    text = text.replace("\n", " ")
    model = "text-embedding-ada-002"
    if embedding_type == 'openai':
        return openai.Embedding.create(input=[text.lower()], model=model)['data'][0]['embedding']
    elif embedding_type == 'fasttext':
        return fasttext_model.get_sentence_vector(text.lower())
    else:
        raise ValueError("Invalid embedding_type. Expected 'openai' or 'fasttext'.")
def remove_non_alphanumeric(text):
    return re.sub(r'[^a-zA-Z0-9\s]', '', text)
def vectorize_query(query):
    return {'question1536': get_embedding(query.lower()),'question300': get_embedding(query.lower())}
def search_collections(vectors, partition_names):
    question1536=vectors['question1536']
    question300=vectors['question300']
    results_dict = {}
    search_params = {
    "metric_type": "L2",  # Distance metric, can be L2, IP (Inner Product), etc.
    "offset": 0,}
    for name in fields_list:
        try:
            if name == 'text':
                collection = Collection(f"{name}_collection")
                collection.load()
                result = collection.search(
                    data=[question1536],
                    anns_field="embeds",
                    param=search_params,
                    limit=10,
                    partition_names=partition_names,
                    output_fields=['uuid', 'text_id'],
                    consistency_level="Strong"
                )
                results_dict[name] = result
            else:
                collection = Collection(f"{name}_collection")
                collection.load()
                result = collection.search(
                    data=[question300],
                    anns_field="embeds",
                    param=search_params,
                    limit=10,
                    partition_names=partition_names,
                    output_fields=['uuid'],
                    consistency_level="Strong"
                )
                results_dict[name] = result
        except MilvusException as e:
            if 'partition name' in str(e) and 'not found' in str(e):
                print(f"Partition '{partition_names}' not found in collection '{name}', skipping...")
                continue
            else:
                raise e  # if it's a different kind of MilvusException, we still want to raise it
    
    return results_dict
def check_collection_dimension(collection):
    collection_params = collection.schema
    vector_field = [field for field in collection_params.fields if field.dtype == DataType.FLOAT_VECTOR][0]
    print(f"Dimension of vectors in collection '{collection.name}': {vector_field.params['dim']}")
def process_results(results_dict):
    json_results = {}

    for collection_name, result in results_dict.items():
        for query_hits in result:
            for hit in query_hits:
                if collection_name == 'text':
                    id_field = 'entity_id'
                    id_value = hit.entity.get('text_id')
                else:
                    id_field = 'entity_id'
                    id_value = hit.id
                
                # Create the result dictionary
                result_dict = {
                    id_field: id_value,
                    "distance": hit.distance,
                    "collection": collection_name
                }

                # If the id_value is already in the results and the new distance is greater, skip
                if id_value in json_results and json_results[id_value]["distance"] < hit.distance:
                    continue

                # Otherwise, update/insert the result
                json_results[id_value] = result_dict
                
            json_results_list = list(json_results.values())
            json_results_sorted = sorted(json_results_list, key=lambda x: x['distance'])
    
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

    # Query for all relevant records at once
    for name, collection in collections.items():
        try:
            # Prepare the query
            output_fields = []
            if name == 'text':
                query_field = "text_id"
                output_fields = [name, 'text_id']
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
                consistency_level="Strong"
            )

            # Append the results to the relevant fields in the results dictionary
            for query_result in query_results:
                for result in json_results_sorted:
                    if (name == 'text' and result["entity_id"] == query_result["text_id"]) or (name != 'text' and result["entity_id"] == query_result["uuid"]):
                        result[name].append(query_result[name])
            final_results = []
            for result in json_results_sorted:
                obj = {}
                for item in result:
                    # If item is not 'entity_id' or 'distance' and the item's value is not empty
                    if item not in ['entity_id', 'collection'] and result[item]:
                        obj[item] = result[item]
                # print(obj)
                final_results.append(obj)
        except Exception as e:
            print(f"Error with collection {name}: {str(e)}")
    return final_results[:10]
def generate_response(prompt, string_json):
    # Format the input as per the desired conversation format
    conversation = [
        {'role': 'system', 'content': """You are Josenian Quiri. University of San Jose- Recoletos' general knowledge base assistant. Refer to yourself as JQ. If there are links, give the link as well."""},
        {'role': 'user', 'content': prompt},
        {'role': 'system', 'content': f'Here is the database JSON from your knowledge base (note: select only the correct answer): \n{string_json[:4500]}]'},
        {'role': 'user', 'content': ''}
    ]
    
    # Convert the conversation to a string
    conversation_str = ''.join([f'{item["role"]}: {item["content"]}\n' for item in conversation])

    response = openai.ChatCompletion.create(
      model="gpt-3.5-turbo",
      messages=conversation,
      temperature=1,
      max_tokens=1000,
      top_p=1,
      frequency_penalty=0,
      presence_penalty=0
    )
    
    # Extract the generated response from the API's response
    generated_text = response['choices'][0]['message']['content']


    # Return the response
    return generated_text
def ranking_partitions(vectors):
    return ['people_partition', 'documents_partition', 'social_posts_partition', "contacts_partition"]
# clf_attribute = joblib.load('lib\models\clf_attribute.pkl')
# clf_partition = joblib.load('lib\models\clf_partition.pkl')

# # load encoders
# le_attribute = joblib.load('lib\models\le_attribute.pkl')
# le_partition = joblib.load('lib\models\le_partition.pkl')

# def predict_attribute(embeds):
#     # transform input to the right format
#     X = np.stack([embeds])

#     # predict probabilities across all possible labels
#     probas = clf_attribute.predict_proba(X)[0]

#     # get class labels in descending order of probability
#     classes = clf_attribute.classes_
#     ranked_classes = [x for _, x in sorted(zip(probas, classes), reverse=True)]

#     # return the names instead of the encoded labels
#     return le_attribute.inverse_transform(ranked_classes)

# def predict_partition(embeds):
#     # transform input to the right format
#     X = np.stack([embeds])

#     # predict probabilities across all possible labels
#     probas = clf_partition.predict_proba(X)[0]

#     # get class labels in descending order of probability
#     classes = clf_partition.classes_
#     ranked_classes = [x for _, x in sorted(zip(probas, classes), reverse=True)]

#     # return the names instead of the encoded labels
#     return le_partition.inverse_transform(ranked_classes)

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
            ranked_partitions = ranking_partitions(vectors['question300'])
            if ranked_partitions is None:
                print("No ranked_partitions returned. Check your ranking_partitions function.")
                continue
            partition = 0
            correct = 0
            while correct != 1:
                results_dict = search_collections(vectors, [ranked_partitions[partition]])
                if results_dict is None:
                    print("No results returned. Check your search_collections function.")
                    break
                json_results_sorted = process_results(results_dict)
                if json_results_sorted is None:
                    print("No sorted results returned. Check your process_results function.")
                    break
                final_results = populate_results(json_results_sorted, ranked_partitions[partition])
                if final_results is None:
                    print("No final results returned. Check your populate_results function.")
                    break
                string_json = json.dumps(final_results)
                display(string_json)
                generated_text = generate_response(prompt, string_json)
                if generated_text is None:
                    print("No response generated. Check your generate_response function.")
                    break
                print(f"JQ: {generated_text}")
                correct = input("Is the answer correct? 1-Y, 0-N: ")
                if correct not in ['0', '1']:
                    print("Invalid input. Try again.")
                elif partition <= 3 :
                    partition = partition + 1
                else:
                    partition = 0
        except Exception as e:
            print(f"An error occurred: {e}")
