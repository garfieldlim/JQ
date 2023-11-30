from joblib import load
from firebase_admin import credentials

# config.py
MILVUS_HOST = "localhost"
MILVUS_PORT = "19530"
OPENAI_API_KEY = "C:/Users/user/Documents/3rd year/Summer/Thesis 1/JQ/jq_admin/lib/newflask/utils/api_key.txt"
TOKENIZER_PATH = "intfloat/e5-large-v2"

SVM_MODEL = load(
    "C:/Users/user/Documents/3rd year/Summer/Thesis 1/JQ/jq_admin/lib/newflask/models/svm_model.joblib"
)
LABEL_ENCODER = load(
    "C:/Users/user/Documents/3rd year/Summer/Thesis 1/JQ/jq_admin/lib/newflask/models/label_encoder.joblib"
)

CRED = credentials.Certificate(
    "C:/Users/user/Documents/3rd year/Summer/Thesis 1/JQ/jq_admin/lib/newflask/utils/josenianquiri-c3c63-firebase-adminsdk-r8ews-1dd8ff0c6e.json"
)

POSTS_JSON_PATH = "C:/Users/user/Documents/3rd year/Summer/Thesis 1/JQ/jq_admin/posts.json"

COOKIES_PATH = "C:/Users/user/Documents/3rd year/Summer/Thesis 1/JQ/jq_admin/lib/newflask/cookies.json"

MAIN_POSTS_JSON_PATH = "C:/Users/user/Documents/3rd year/Summer/Thesis 1/JQ"