from torch import Tensor
from transformers import AutoTokenizer, AutoModel
import torch.nn.functional as F


def average_pool(last_hidden_states: Tensor, attention_mask: Tensor) -> Tensor:
    last_hidden = last_hidden_states.masked_fill(~attention_mask[..., None].bool(), 0.0)
    return last_hidden.sum(dim=1) / attention_mask.sum(dim=1)[..., None]


def get_embedding(text):
    # Load the tokenizer and model
    tokenizer = AutoTokenizer.from_pretrained("intfloat/e5-large-v2")
    model = AutoModel.from_pretrained("intfloat/e5-large-v2")

    # Prefix the text with 'query: '
    text = "query: " + text

    # Tokenize the input text
    inputs = tokenizer(
        text, max_length=512, padding=True, truncation=True, return_tensors="pt"
    )

    # Generate model outputs
    outputs = model(**inputs)

    # Average pool the last hidden states and apply the attention mask
    embeddings = average_pool(outputs.last_hidden_state, inputs["attention_mask"])

    # Normalize the embeddings
    embeddings = F.normalize(embeddings, p=2, dim=1)

    # Convert tensor to list
    embeddings_list = embeddings.tolist()

    return embeddings_list[0]


def vectorize_query(query):
    return get_embedding(query.lower())
