from facebook_scraper import get_post
from flask import Flask, request, jsonify
from flask_cors import CORS
import json

app = Flask(__name__)
CORS(app)

@app.route('/scrape_facebook', methods=['POST'])
def scrape_facebook():
    data = request.get_json()

    if 'url' not in data:
        return jsonify({'error': 'No URL provided'}), 400

    url = data['url']
    post_id = url.split('/')[-2]  # extract post id from url

    try:
        post = get_post(post_id, options={"cookies": "C:Users/Jillian/Documents/scrape/cookies.json"})
        print(f"Scraped data: {post}")  # Log the scraped data
        return jsonify(post), 200
    except Exception as e:
        return jsonify({'error': 'Error while scraping the post'}), 400

if __name__ == "__main__":
    app.run(port=5000)
