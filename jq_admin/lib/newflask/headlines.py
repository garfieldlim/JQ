import datetime
import json
import os
import time
from facebook_scraper import get_posts
from config import POSTS_JSON_PATH, COOKIES_PATH


class DateTimeEncoder(json.JSONEncoder):
    """Custom encoder for datetime objects."""

    def default(self, obj):
        if isinstance(obj, datetime.datetime):
            return obj.isoformat()
        return super().default(obj)


def fetch_facebook_posts(page_name, tag, base_url, start_url):
    """Fetch Facebook posts for a given page using specified base URL and start URL."""
    posts = []
    try:
        for i, post in enumerate(
            get_posts(
                account=page_name,
                base_url=base_url,
                start_url=start_url,
                pages=1,
                cookies=COOKIES_PATH,
            ),
            start=1,
        ):
            post["text"] = f"{tag}: {post['text']}"
            posts.append(post)
            time.sleep(1)
    except Exception as error:
        print(f"Error fetching posts from {page_name}: {error}")
    return posts


def save_posts_to_file(posts, file_path):
    """Save posts to a JSON file."""
    with open(file_path, "w", encoding="utf-8") as file:
        json.dump(posts, file, cls=DateTimeEncoder, indent=4)


def update_posts_json():
    """Main function to update or create posts.json."""
    print("Updating posts.json...")

    # Remove the existing file if it exists
    if os.path.isfile(POSTS_JSON_PATH):
        os.remove(POSTS_JSON_PATH)
        print(f"Existing posts.json file removed.")

    # Define base_url and start_url for each page
    base_url = "https://mbasic.facebook.com"
    start_url_forward = "https://mbasic.facebook.com/usjrforward?v=timeline"
    start_url_official = "https://mbasic.facebook.com/usjr.official?v=timeline"

    posts_from_forward = fetch_facebook_posts(
        "usjrforward", "usjrforward", base_url, start_url_forward
    )
    posts_from_official = fetch_facebook_posts(
        "usjr.official", "usjr.official", base_url, start_url_official
    )

    combined_posts = posts_from_forward + posts_from_official

    if combined_posts:
        save_posts_to_file(combined_posts, POSTS_JSON_PATH)
        print("posts.json has been updated with the latest posts.")
    else:
        print("No new posts were fetched.")


# import datetime
# import os
# import time
# from facebook_scraper import get_posts
# import json
# from config import POSTS_JSON_PATH, COOKIES_PATH


# class DateTimeEncoder(json.JSONEncoder):
#     """Custom encoder for datetime objects."""

#     def default(self, obj):
#         if isinstance(obj, datetime.datetime):
#             return obj.isoformat()
#         return super().default(obj)


# def get_facebook_posts():
#     headers = {
#         "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
#     }

#     existing_posts = []
#     existing_ids = set()

#     posts_json_path = POSTS_JSON_PATH

#     # Attempt to read existing posts from the JSON file
#     if os.path.isfile(posts_json_path):
#         try:
#             with open(posts_json_path, "r", encoding="utf-8") as f:
#                 existing_posts = json.load(f)
#                 existing_ids = {post["post_id"] for post in existing_posts}
#         except json.JSONDecodeError as e:
#             print(f"Error reading {posts_json_path}: {e}")
#             # Handle the corrupted JSON file (e.g., rename it for backup)
#             corrupted_path = posts_json_path + ".corrupted"
#             os.rename(posts_json_path, corrupted_path)
#             print(f"Renamed corrupted file to {corrupted_path}")

#     def fetch_and_tag_posts(page_name, tag):
#         posts = []
#         try:
#             for i, post in enumerate(
#                 get_posts(
#                     page_name,
#                     cookies=COOKIES_PATH,
#                     pages=2,
#                     options={"headers": headers},
#                 ),
#                 start=1,
#             ):
#                 if post["post_id"] not in existing_ids:
#                     post["text"] = f"{tag}: {post['text']}"
#                     print(f"Count {i}: {post['text']}")
#                     posts.append(post)
#                     existing_ids.add(post["post_id"])
#                     time.sleep(1)
#         except Exception as e:
#             print(f"Error fetching posts from {page_name}: {e}")
#         return posts

#     # Fetch posts from usjrforward and usjr.official
#     posts_from_forward = fetch_and_tag_posts("usjrforward", "usjrforward")
#     posts_from_official = fetch_and_tag_posts("usjr.official", "usjr.official")

#     # Combine the posts from both sources
#     combined_posts = posts_from_forward + posts_from_official

#     # Append new posts to existing posts
#     existing_posts.extend(combined_posts)

#     # Save the combined list of posts into the JSON file
#     with open("posts.json", "w", encoding="utf-8") as f:
#         json.dump(existing_posts, f, cls=DateTimeEncoder, indent=4)

#     return json.dumps(existing_posts, cls=DateTimeEncoder, indent=4)


# def update_posts_json():
#     posts_json_path = (
#         POSTS_JSON_PATH  # Assuming posts.json is in the current working directory
#     )

#     # If posts.json exists, delete it and write the new posts
#     if os.path.isfile(posts_json_path):
#         os.remove(posts_json_path)

#     # Fetch new posts
#     new_posts_json = get_facebook_posts()

#     # Check if there are new posts
#     if new_posts_json:
#         new_posts = json.loads(
#             new_posts_json
#         )  # Parse the JSON string into a Python list
#         # Write the new posts
#         with open(posts_json_path, "w", encoding="utf-8") as file:
#             json.dump(new_posts, file, cls=DateTimeEncoder, indent=4)
#         print("posts.json has been updated with the latest posts.")
#     else:
#         print("No posts were fetched.")
