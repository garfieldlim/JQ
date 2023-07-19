from datetime import datetime
from pymilvus import connections, Collection
import numpy as np
import openai
import json

# Constants
OPENAI_API_KEY = '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'
EMBEDDING_MODEL = "text-embedding-ada-002"
EMBEDDING_ENCODING = "cl100k_base"
MAX_TOKENS = 8000
DIMENSIONS = 1536
PARTITION_NAME = 'facebook_posts'
BUNDLED_SCHEMA = {'rmrj_articles': ['author', 'title', 'published_date', 'text'],
                  'facebook_posts': ['text', 'time', 'link'],
                  'usjr_about': ['text', 'content_id'],
                  'all': ['author', 'title', 'published_date', 'text', 'time', 'post', 'link', 'content_id']}
COLLECTION_NAMES = BUNDLED_SCHEMA[PARTITION_NAME]

openai.api_key = OPENAI_API_KEY

# Function definitions
def get_embedding(text, model=EMBEDDING_MODEL):
   text = text.replace("\n", " ")
   return openai.Embedding.create(input=[text], model=model)['data'][0]['embedding']

def connect_to_milvus():
    if connections.has_connection('default'):
        connections.remove_connection('default')  
    connections.connect(alias='default', host='localhost', port='19530')

def create_search_params():
    return {
        "metric_type": "L2",
        "offset": 0,
    }

def search_collections(search_params, query_vectors):
    results = []
    for name in COLLECTION_NAMES:
        collection = Collection(f"{name}_collection")
        collection.load()
        result = collection.search(
            data=query_vectors,
            anns_field="embeds",
            param=search_params,
            limit=5,
            partition_names=[PARTITION_NAME],
            output_fields=[name, 'uuid'],
            consistency_level="Strong"
        )
        results.append(result)
    return results

def process_search_results(results):
    unique_results = {}
    for i, name in enumerate(COLLECTION_NAMES):
        for result in results[i]:
            for item in result:
                uuid = item.entity.get('uuid')
                data = {
                    'uuid': uuid,
                    name: item.entity.get(name),
                    'distance': item.distance
                }
                if uuid not in unique_results or item.distance < unique_results[uuid]['distance']:
                    unique_results[uuid] = data
    results_object = list(unique_results.values())
    sorted_results = sorted(results_object, key=lambda x: x['distance'])
    return sorted_results[:5]

def complete_fields(final_results):
    for result in final_results:
        for name in COLLECTION_NAMES:
            if name not in result:
                collection = Collection(f"{name}_collection")
                query = f'uuid == "{result["uuid"]}"'
                query_result = collection.query(
                    expr=query, 
                    offset=0, 
                    limit=1, 
                    partition_names=[PARTITION_NAME], 
                    output_fields=[name], 
                    consistency_level="Strong"
                )
                if query_result:
                    result[name] = query_result[0][name]
    return final_results

def print_results(final_results):
    for i, result in enumerate(final_results):
        print(f"Result {i}: ", result,"\n")

def generate_response(prompt, database_json):
    string_json = json.dumps(database_json)
    conversation = [
        {'role': 'system', 'content': "You are Josenian Quiri. University of San Jose- Recoletos' general knowledge base assistant. Refer to yourself as JQ."},
        {'role': 'user', 'content': prompt},
        {'role': 'system', 'content': f'Here is the database JSON from your knowledge base: \n{string_json}'},
        {'role': 'user', 'content': ''}
    ]
    conversation_str = ''.join([f'{item["role"]}: {item["content"]}\n' for item in conversation])

    response = openai.ChatCompletion.create(
      model="gpt-4",
      messages=conversation,
      temperature=1,
      max_tokens=500,
      top_p=1,
      frequency_penalty=0,
      presence_penalty=0
    )
    return response['choices'][0]['message']['content']


# Main function
def main():
    question = "What are the DOST USJR privileges?"
    query_vectors = np.array(get_embedding(question)).reshape(1, -1)

    connect_to_milvus()

    search_params = create_search_params()

    search_results = search_collections(search_params, query_vectors)

    sorted_results = process_search_results(search_results)

    final_results = complete_fields(sorted_results)

    print_results(final_results)

    response = generate_response(question, final_results)
    print(response)


if __name__ == "__main__":
    main()
