from flask import Flask, request, jsonify
from flask_cors import CORS
from facebook_scraper import get_posts

import json
from datetime import datetime

from flask import Flask
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
from firebase_admin import firestore
from config import CRED, COOKIES_PATH, POSTS_JSON_PATH

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


cred = CRED
firebase_admin.initialize_app(cred)


@app.route("/save_chat_message", methods=["POST"])
def save_chat_message():
    data = request.json
    db = firestore.client()

    timestamp = datetime.now().isoformat()

    # Save user message
    user_message_data = data["userMessage"]
    user_message_data["timestamp"] = timestamp
    user_message_ref = db.collection("chat_messages").document(data["userMessageId"])
    user_message_data["id"] = user_message_ref.id
    user_message_data["isUserMessage"] = True

    # Save bot message
    bot_message_data = data["botMessage"]
    bot_message_data["timestamp"] = timestamp
    bot_message_ref = db.collection("chat_messages").document(data["botMessageId"])
    bot_message_data["id"] = bot_message_ref.id
    bot_message_data["foreignId"] = user_message_ref.id
    user_message_data["foreignId"] = bot_message_ref.id
    bot_message_data["liked"] = data.get("liked", False)
    bot_message_data["disliked"] = data.get("disliked", False)
    bot_message_data["isUserMessage"] = False
    bot_message_data["partitionName"] = data.get("partitionName", "")
    bot_message_data["milvusData"] = data.get("milvusData", {})
    bot_message_ref.set(bot_message_data)
    user_message_ref.set(user_message_data)

    return jsonify({"status": "success"})


@app.route("/update_chat_message_like_dislike", methods=["POST"])
def update_chat_message_like_dislike():
    data = request.json
    db = firestore.client()

    bot_message_id = data.get("botMessageId")
    if bot_message_id:
        bot_message_ref = db.collection("chat_messages").document(bot_message_id)

        # Check if the document exists
        if bot_message_ref.get().exists:
            bot_message_ref.update(
                {
                    "liked": data.get("liked", False),
                    "disliked": data.get("disliked", False),
                }
            )
            return jsonify({"status": "success"})
        else:
            return jsonify({"status": "failure", "message": "Document not found"})
    else:
        return jsonify({"status": "failure", "message": "Missing botMessageId"})

    return jsonify({"status": "error"})


update_posts_json()


@app.route("/posts", methods=["GET"])
def read_posts_json():
    try:
        with open(POSTS_JSON_PATH, "r") as file:
            posts = json.load(file)
        return jsonify(posts)
    except Exception as e:
        return jsonify({"error": str(e)}), 404


@app.route("/scrape_website", methods=["POST"])
def scrape_website():
    url = request.json["url"]
    cookies_path = COOKIES_PATH

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

    # print(final_results)
    generated_text = generate_response(prompt, final_results)
    # print(generated_text)
    if generated_text is None:
        return jsonify(
            {"error": "No response generated. Check your generate_response function."}
        )
    # string_json = json.dumps(final_results, cls=DateTimeEncoder)
    return jsonify(
        {
            "response": generated_text,
            "milvusData": final_results,
            "partitionName": partition_name,
        }
    )


@app.route("/get_data/<partition_name>", methods=["GET"])
def get_data(partition_name):
    combined_data = combine_results_by_uuid(partition_name)
    table_data = create_table(combined_data, partition_name)
    print(table_data)
    return jsonify(table_data)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=7999)
