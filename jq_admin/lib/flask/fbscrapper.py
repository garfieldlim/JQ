from flask import Flask, request, jsonify
import json
import datetime
from facebook_scraper import get_posts

from flask_cors import CORS

app = Flask(__name__)
CORS(app)

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
    for post in get_posts(post_urls=[url], cookies="C:/Users/Jillian/Documents/scrape/cookies.json"):
        # post_json = json.dumps(post, cls=DateTimeEncoder)  
        scraped_data.append(post)

    return jsonify(scraped_data)

if __name__ == '__main__':
    app.run( port=5000,debug=True)
