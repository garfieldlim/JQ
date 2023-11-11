from joblib import load

# config.py
MILVUS_HOST = "localhost"
MILVUS_PORT = "19530"
OPENAI_API_KEY = "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"
TOKENIZER_PATH = "intfloat/e5-large-v2"

SVM_MODEL = load(
    "/Users/garfieldgreglim/Documents/JQ/jq_admin/lib/newflask/models/svm_model.joblib"
)
LABEL_ENCODER = load(
    "/Users/garfieldgreglim/Documents/JQ/jq_admin/lib/newflask/models/label_encoder.joblib"
)
