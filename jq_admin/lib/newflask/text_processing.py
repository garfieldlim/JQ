import re


def remove_non_alphanumeric(text):
    return re.sub(r"[^a-zA-Z0-9\s]", "", text)
