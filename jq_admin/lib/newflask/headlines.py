import datetime
import os
import time
from facebook_scraper import get_posts
import json
from config import POSTS_JSON_PATH, COOKIES_PATH


class DateTimeEncoder(json.JSONEncoder):
    """Custom encoder for datetime objects to ensure they are serialized into JSON compatible format."""

    def default(self, obj):
        # If the object is a datetime object, convert it to its ISO 8601 string representation.
        if isinstance(obj, datetime.datetime):
            return obj.isoformat()
        # Otherwise, use the standard default method for encoding.
        return super().default(obj)


def get_facebook_posts():
    print("Starting the process to get Facebook posts...")
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    print(f"User-Agent for requests: {headers['User-Agent']}")

    existing_posts = []
    existing_ids = set()
    print("Initialized containers for storing post data.")

    posts_json_path = POSTS_JSON_PATH
    print(f"Posts will be stored in: {posts_json_path}")

    if os.path.isfile(posts_json_path):
        print(
            f"Existing posts JSON file found at {posts_json_path}. Attempting to read..."
        )
        try:
            with open(posts_json_path, "r", encoding="utf-8") as f:
                existing_posts = json.load(f)
                existing_ids = {post["post_id"] for post in existing_posts}
                print("Successfully read existing posts.")
        except json.JSONDecodeError as e:
            print(f"Error reading {posts_json_path}: {e}")
            corrupted_path = posts_json_path + ".corrupted"
            os.rename(posts_json_path, corrupted_path)
            print(f"Renamed corrupted file to {corrupted_path}")

    def fetch_and_tag_posts(page_name, tag):
        print(f"Fetching and tagging posts from page: {page_name} with tag: '{tag}'")
        posts = []
        try:
            for i, post in enumerate(
                get_posts(
                    page_name,
                    cookies=COOKIES_PATH,
                    pages=1,
                    options={"headers": headers},
                ),
                start=1,
            ):
                print(f"Processing post {i} from {page_name}")
                if post["post_id"] not in existing_ids:
                    post["text"] = f"{tag}: {post['text']}"
                    posts.append(post)
                    existing_ids.add(post["post_id"])
                    print(f"Post with ID {post['post_id']} added with tag '{tag}'.")
                    time.sleep(1)
                else:
                    print(f"Post with ID {post['post_id']} already exists. Skipping.")
        except Exception as e:
            print(f"Error fetching posts from {page_name}: {e}")
        return posts

    posts_from_forward = fetch_and_tag_posts("usjrforward", "usjrforward")
    posts_from_official = fetch_and_tag_posts("usjr.official", "usjr.official")

    combined_posts = existing_posts + posts_from_forward + posts_from_official
    print(f"A total of {len(combined_posts)} posts have been combined.")

    with open(posts_json_path, "w", encoding="utf-8") as f:
        json.dump(combined_posts, f, cls=DateTimeEncoder, indent=4)
        print(f"Combined posts have been written to {posts_json_path}.")

    return json.dumps(combined_posts, cls=DateTimeEncoder, indent=4)


def update_posts_json():
    print("Updating the posts JSON file with new data...")
    posts_json_path = POSTS_JSON_PATH

    if os.path.isfile(posts_json_path):
        os.remove(posts_json_path)
        print(f"Removed existing file: {posts_json_path}")

    new_posts_json = get_facebook_posts()
    print("Retrieved new Facebook posts.")

    if new_posts_json:
        new_posts = json.loads(new_posts_json)
        with open(posts_json_path, "w", encoding="utf-8") as file:
            json.dump(new_posts, file, cls=DateTimeEncoder, indent=4)
        print("posts.json has been updated with the latest posts.")
    else:
        print("No posts were fetched.")


if __name__ == "__main__":
    print("Script execution started.")
    update_posts_json()
    print("Script execution completed.")
