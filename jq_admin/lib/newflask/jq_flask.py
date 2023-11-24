from flask import Flask, request, jsonify
from flask_cors import CORS
from facebook_scraper import get_posts

import json
import datetime
import time
from flask import Flask, send_from_directory
from database import (
    populate_results,
    rank_partitions,
    search_collections,
    sort_results,
)

from embeddings import vectorize_query
from headlines import update_posts_json
from knowledgebase_crud import (
    combine_results_by_uuid,
    create_table,
    process_object,
)
from openai_api import generate_response
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

app = Flask(__name__)
CORS(app)  # This will enable CORS for all routes
from pymilvus import (
    connections,
)

# Check if the connection already exists
if connections.has_connection("default"):
    connections.remove_connection("default")  # Disconnect if it exists

# Now, reconnect with your new configuration
connections.connect(alias="default", host="localhost", port="19530")


class DateTimeEncoder(json.JSONEncoder):
    """Custom encoder for datetime objects."""

    def default(self, obj):
        if isinstance(obj, datetime.datetime):
            return obj.isoformat()
        return super().default(obj)


# @app.route("/posts", methods=["GET"])
# def get_facebook_posts():
#     headers = {
#         "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
#     }

#     try:
#         with open("posts.json", "r", encoding="utf-8") as f:
#             existing_posts = json.load(f)
#     except FileNotFoundError:
#         existing_posts = []

#     existing_ids = {post["post_id"] for post in existing_posts}

#     posts = []
#     try:
#         for i, post in enumerate(
#             get_posts(
#                 "usjrforward",
#                 cookies="lib/newflask/cookies.json",
#                 pages=5,
#                 options={"headers": headers},
#             ),
#             start=1,
#         ):
#             if post["post_id"] in existing_ids:
#                 print(f"Skipping duplicate post: {post['post_id']}")
#                 continue
#             print(f"Count {i}: {post['text']}")
#             posts.append(post)
#             existing_ids.add(post["post_id"])
#             time.sleep(1)
#     except Exception as e:
#         print(f"Error: {e}")

#     #     # Append new posts to existing posts
#     #     existing_posts.extend(posts)

#     # Save the combined list of posts into the JSON file
#     with open("posts.json", "w", encoding="utf-8") as f:
#         json.dump(existing_posts, f, cls=DateTimeEncoder, indent=4)

#     print(existing_posts)
#     return jsonify(existing_posts)
cred = credentials.Certificate("C:/Users/user/Documents/3rd year/Summer/Thesis 1/JQ/jq_admin/lib/newflask/utils/josenianquiri-c3c63-firebase-adminsdk-r8ews-1dd8ff0c6e.json")
firebase_admin.initialize_app(cred)

@app.route("/save_chat_message", methods=["POST"])
def save_chat_message():
    data = request.json
    db = firestore.client()

    # Save user message
    user_message_ref = db.collection('chat_messages').document()    
    user_message_data = data['userMessage']
    user_message_data['isUserMessage'] = True
    user_message_ref.set(user_message_data)

    # Save bot message
    bot_message_ref = db.collection('chat_messages').document()
    bot_message_data = data['botMessage']
    bot_message_data['liked'] = data.get('liked', False)
    bot_message_data['disliked'] = data.get('disliked', False)
    bot_message_data['isUserMessage'] = False
    bot_message_data['partitionName'] = data.get('partitionName', '')
    bot_message_data['milvusData'] = data.get('milvusData', {})    
    bot_message_ref.set(bot_message_data)

    return jsonify({"status": "success", "user_message_id": user_message_ref.id, "bot_message_id": bot_message_ref.id})

@app.route("/update_chat_message_like_dislike", methods=["POST"])
def update_chat_message_like_dislike():
    data = request.json
    db = firestore.client()

    # Update bot message like/dislike status
    bot_message_id = data.get('botMessageId')
    if bot_message_id:
        bot_message_ref = db.collection('chat_messages').document(bot_message_id)
        bot_message_ref.update({'liked': data.get('liked', False), 'disliked': data.get('disliked', False)})

    return jsonify({"status": "success"})

update_posts_json()

@app.route('/posts')
def get_posts():
    directory = 'C:/Users/user/Documents/3rd year/Summer/Thesis 1/JQ'  # Directory path where posts.json is located
    return send_from_directory(directory, 'posts.json')

@app.route("/scrape_website", methods=["POST"])
def scrape_website():
    url = request.json["url"]
    cookies_path = "C:/Users/user/Documents/3rd year/Summer/Thesis 1/JQ/jq_admin/lib/newflask/cookies.json"

    scraped_data = [post for post in get_posts(post_urls=[url], cookies=cookies_path)]

    return jsonify(scraped_data)


@app.route("/receive_json", methods=["POST"])
def receive_json():
    data = request.json
    process_object(data)
    return jsonify({"status": "success"})


@app.route("/query", methods=["POST"])
def question_answer():
    prompt = request.json["question"]

    print(prompt)

    vectors = vectorize_query(prompt)
    if vectors is None:
        return jsonify(
            {"error": "No vectors returned. Check your vectorize_query function."}
        )

    ranked_partitions = rank_partitions(vectors)
    if ranked_partitions is None:
        return jsonify(
            {
                "error": "No ranked partitions returned. Check your rank_partitions function."
            }
        )

    partition = request.json.get("partition", 0)
    results_dict = search_collections(vectors, [ranked_partitions[partition]])
    partition_name = ranked_partitions[partition]
    if results_dict is None:
        return jsonify(
            {"error": "No results returned. Check your search_collections function."}
        )

    json_results_sorted = sort_results(results_dict)
    if json_results_sorted is None:
        return jsonify(
            {
                "error": "No sorted results returned. Check your process_results function."
            }
        )

    final_results = populate_results(json_results_sorted, ranked_partitions[partition])
    if final_results is None:
        return jsonify(
            {
                "error": "No final results returned. Check your populate_results function."
            }
        )
    print(final_results)
    generated_text = generate_response(prompt, final_results)
    print(generated_text)
    if generated_text is None:
        return jsonify(
            {"error": "No response generated. Check your generate_response function."}
        )
    # string_json = json.dumps(final_results, cls=DateTimeEncoder)
    return jsonify({
        "response": generated_text,
        "milvusData": final_results,
        "partitionName": partition_name
    })


@app.route("/get_data/<partition_name>", methods=["GET"])
def get_data(partition_name):
    combined_data = combine_results_by_uuid(partition_name)
    table_data = create_table(combined_data, partition_name)
    print(table_data)
    return jsonify(table_data)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=7999)
