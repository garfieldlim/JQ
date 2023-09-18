from flask import Flask, request, jsonify
from flask_cors import CORS
from facebook_scraper import get_posts
from helper_functions import (
    vectorize_query, 
    process_object, 
    rank_partitions,
    search_collections, 
    process_results, 
    populate_results, 
    generate_response
)
import json
import datetime

app = Flask(__name__)
CORS(app)  # This will enable CORS for all routes


class DateTimeEncoder(json.JSONEncoder):
    """Custom encoder for datetime objects."""
    def default(self, obj):
        if isinstance(obj, datetime.datetime):
            return obj.isoformat()
        return super().default(obj)


@app.route('/scrape_website', methods=['POST'])
def scrape_website():
    url = request.json['url']
    cookies_path = "C:/Users/user/Documents/3rd year/Summer/Thesis 1/JQ/jq_admin/lib/flask/cookies.json"
    
    scraped_data = [
        post for post in get_posts(post_urls=[url], cookies=cookies_path)
    ]
    
    return jsonify(scraped_data)


@app.route('/receive_json', methods=['POST'])
def receive_json():
    data = request.json
    process_object(data)
    return jsonify({'status': 'success'})


@app.route('/query', methods=['POST'])
def question_answer():
    prompt = request.json['question']

    print(prompt)

    vectors = vectorize_query(prompt)
    if vectors is None:
        return jsonify({"error": "No vectors returned. Check your vectorize_query function."})

    ranked_partitions = rank_partitions(vectors)
    if ranked_partitions is None:
        return jsonify({"error": "No ranked partitions returned. Check your rank_partitions function."})

    partition = request.json.get('partition', 0)
    results_dict = search_collections(vectors, [ranked_partitions[partition]])
    if results_dict is None:
        return jsonify({"error": "No results returned. Check your search_collections function."})

    json_results_sorted = process_results(results_dict)
    if json_results_sorted is None:
        return jsonify({"error": "No sorted results returned. Check your process_results function."})

    final_results = populate_results(json_results_sorted, ranked_partitions[partition])
    if final_results is None:
        return jsonify({"error": "No final results returned. Check your populate_results function."})

    generated_text = generate_response(prompt, final_results)
    if generated_text is None:
        return jsonify({"error": "No response generated. Check your generate_response function."})

    return jsonify({"response": generated_text})
@app.route("/get_data/<partition_name>", methods=["GET"])
def get_data(partition_name):
    combined_data = combine_results_by_uuid(partition_name)
    print("hi")
    table_data = create_table(combined_data, partition_name)
    print(table_data)
    return jsonify(table_data)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=7999)
