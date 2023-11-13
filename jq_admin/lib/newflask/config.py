from joblib import load

# config.py
MILVUS_HOST = "localhost"
MILVUS_PORT = "19530"
OPENAI_API_KEY = "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"
TOKENIZER_PATH = "intfloat/e5-large-v2"

SVM_MODEL = load(
    "lib/newflask/models/svm_model.joblib"
)
LABEL_ENCODER = load(
    "lib/newflask/models/label_encoder.joblib"
)
