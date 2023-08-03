from flask import Flask, request, jsonify
import json
import datetime
from facebook_scraper import get_posts
from helper_functions import process_object
from flask_cors import CORS

from flask_cors import CORS

app = Flask(__name__)
CORS(app) # Enable CORS for all routes

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
    for post in get_posts(post_urls=[url], cookies="jq_admin/lib/flask/cookies.json"):
        post_json = post # No need to convert to string here
        scraped_data.append(post_json)

    return jsonify(scraped_data) # Return list of dictionaries

@app.route('/receive_json', methods=['POST'])
def receive_json():
    # Get the JSON data from the request
    data = request.json
    process_object(data)
    return jsonify({'status': 'success'})


if __name__ == '__main__':
    app.run( port=5000,debug=True)
