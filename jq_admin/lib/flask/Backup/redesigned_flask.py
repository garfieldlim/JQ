from flask import Flask, request, jsonify
from helper_functions import vectorize_query, process_object, ranking_partitions, search_collections, process_results, populate_results, generate_response, rank_partitions
import json
import datetime
from flask import Flask, request, jsonify
import json
import datetime
from facebook_scraper import get_posts
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # This will enable CORS for all routes


@app.route('/scrape_website', methods=['POST'])
def scrape_website():
    url = request.json['url']

    # Custom encoder for datetime objects
    class DateTimeEncoder(json.JSONEncoder):
        def default(self, obj):
            if isinstance(obj, datetime.datetime):
                return obj.isoformat()
            return json.JSONEncoder.default(self, obj)

    scraped_data = []
    for post in get_posts(post_urls=[url], cookies="/Users/garfieldgreglim/Documents/JQ/jq_admin/lib/flask/cookies.json"):
        post_json = post # No need to convert to string here
        scraped_data.append(post_json)

    return jsonify(scraped_data) # Return list of dictionaries

@app.route('/receive_json', methods=['POST'])
def receive_json():
    # Get the JSON data from the request
    data = request.json
    process_object(data)
    return jsonify({'status': 'success'})


@app.route('/query', methods=['POST'])
def question_answer():
    prompt = request.json['question']
    prev_message = request.json.get('prev')
    print(f"THIS IS PROMPT : {prompt} ")
    print(f"THIS IS PREV MESSAGE : {prev_message} ")
    if prev_message == 'How may I help you?':
        prev_message = ' '
    #  if prev_message has 'announcement', prev_message == ' '
    if 'announcement' in prev_message:
        prev_message = ' '


    vectors = vectorize_query(prompt+ ' ' + prev_message)
    print("Vectors done.")
    if vectors is None:
        return jsonify({"error": "No vectors returned. Check your vectorize_query function."})

    ranked_partitions = rank_partitions(vectors)
    if ranked_partitions is None:
        return jsonify({"error": "No ranked_partitions returned. Check your ranking_partitions function."})
    print("Partitions ranked.")

    partition = request.json.get('partition', 0)
    results_dict = search_collections(vectors, [ranked_partitions[partition]])
    print("Results dic done.")
    if results_dict is None:
        return jsonify({"error": "No results returned. Check your search_collections function."})

    json_results_sorted = process_results(results_dict)
    print("JSON sorted done.")
    if json_results_sorted is None:
        return jsonify({"error": "No sorted results returned. Check your process_results function."})

    final_results = populate_results(json_results_sorted, ranked_partitions[partition])
    print("Populate results done.")
    if final_results is None:
        return jsonify({"error": "No final esults returned. Check your populate_results function."})
    
    string_json = final_results
    print("JSON string done.")
    print("JSOdsnfjksdnjkfdsnjklsdnfjklNS", string_json[:4500])
    print("HGSDUGHSUDHFSDFJILDSFDISJDF,", prev_message)
    generated_text = generate_response(f"{prompt}")
    print(generated_text)
    if generated_text is None:
        return jsonify({"error": "No response generated. Check your generate_response function."})

    return jsonify({"response": generated_text})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=7999)