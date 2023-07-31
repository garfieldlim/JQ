from flask import Flask, request, jsonify
from helper_functions import vectorize_query, ranking_partitions, search_collections, process_results, populate_results, generate_response
import json
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # This will enable CORS for all routes

@app.route('/query', methods=['POST'])
def question_answer():
    prompt = request.json['question']
    
    vectors = vectorize_query(prompt)
    print("Vectors done.")
    if vectors is None:
        return jsonify({"error": "No vectors returned. Check your vectorize_query function."})

    ranked_partitions = ranking_partitions(vectors['question300'])
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
        return jsonify({"error": "No final results returned. Check your populate_results function."})
    
    string_json = json.dumps(final_results)
    print("JSON string done.")
    print("JSOdsnfjksdnjkfdsnjklsdnfjklNS", string_json)
    generated_text = generate_response(prompt, string_json)
    if generated_text is None:
        return jsonify({"error": "No response generated. Check your generate_response function."})

    return jsonify({"response": generated_text})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=7999)
