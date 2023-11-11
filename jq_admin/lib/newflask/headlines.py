import datetime
import os
import time
from facebook_scraper import get_posts
import json


class DateTimeEncoder(json.JSONEncoder):
    """Custom encoder for datetime objects."""

    def default(self, obj):
        if isinstance(obj, datetime.datetime):
            return obj.isoformat()
        return super().default(obj)


def get_facebook_posts():
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }

    existing_posts = []
    existing_ids = set()

    posts_json_path = "C:/Users/user/Documents/3rd year/Summer/Thesis 1/JQ/posts.json"

    # Attempt to read existing posts from the JSON file
    if os.path.isfile(posts_json_path):
        try:
            with open(posts_json_path, "r", encoding="utf-8") as f:
                existing_posts = json.load(f)
                existing_ids = {post["post_id"] for post in existing_posts}
        except json.JSONDecodeError as e:
            print(f"Error reading {posts_json_path}: {e}")
            # Handle the corrupted JSON file (e.g., rename it for backup)
            corrupted_path = posts_json_path + ".corrupted"
            os.rename(posts_json_path, corrupted_path)
            print(f"Renamed corrupted file to {corrupted_path}")

    posts = []
    try:
        for i, post in enumerate(
            get_posts(
                "usjrforward",
                cookies="C:/Users/user/Documents/3rd year/Summer/Thesis 1/JQ/jq_admin/lib/flask/cookies.json",
                pages=2,
                options={"headers": headers},
            ),
            start=1,
        ):
            if post["post_id"] in existing_ids:
                print(f"Skipping duplicate post: {post['post_id']}")
                continue
            print(f"Count {i}: {post['text']}")
            posts.append(post)
            existing_ids.add(post["post_id"])
            time.sleep(1)
    except Exception as e:
        print(f"Error: {e}")

    # Append new posts to existing posts
    existing_posts.extend(posts)

    # Save the combined list of posts into the JSON file
    with open("posts.json", "w", encoding="utf-8") as f:
        json.dump(existing_posts, f, cls=DateTimeEncoder, indent=4)

    return json.dumps(existing_posts, cls=DateTimeEncoder, indent=4)


def update_posts_json():
    posts_json_path = "C:/Users/user/Documents/3rd year/Summer/Thesis 1/JQ/posts.json"  # Assuming posts.json is in the current working directory

    # If posts.json exists, delete it and write the new posts
    if os.path.isfile(posts_json_path):
        os.remove(posts_json_path)

    # Fetch new posts
    new_posts_json = get_facebook_posts()

    # Check if there are new posts
    if new_posts_json:
        new_posts = json.loads(
            new_posts_json
        )  # Parse the JSON string into a Python list
        # Write the new posts
        with open(posts_json_path, "w", encoding="utf-8") as file:
            json.dump(new_posts, file, cls=DateTimeEncoder, indent=4)
        print("posts.json has been updated with the latest posts.")
    else:
        print("No posts were fetched.")
