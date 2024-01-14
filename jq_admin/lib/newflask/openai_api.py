import openai
from config import OPENAI_API_KEY
from nltk.tokenize import word_tokenize
import nltk


def generate_response(prompt, string_json):
    # Format the input as per the desired conversation format
    openai.api_key_path = OPENAI_API_KEY
    string_json = (
        " ".join(string_json) if isinstance(string_json, list) else string_json
    )
    tokens = word_tokenize(string_json)

    # Limit to 10,000 tokens
    print("TOKENS: ", len(tokens))
    if len(tokens) > 10000:
        tokens = tokens[:9000]
    print("TOKENS: ", len(tokens))
    # Join the tokens back into a string
    string_json = " ".join(tokens)
    print("PROMPT: ", prompt)
    # print("STRING JSON: ", string_json)
    conversation = [
        {
            "role": "system",
            "content": """You are Josenian Quiri. University of San Jose- Recoletos' general knowledge base assistant. Refer to yourself as JQ. If there are links, give the link as well.""",
        },
        {"role": "user", "content": prompt},
        {
            "role": "system",
            "content": f"Here is the returned data from your knowledge base (note: select only the correct answer): \n{string_json}]",
        },
        {"role": "user", "content": ""},
    ]

    # Convert the conversation to a string
    conversation_str = "".join(
        [f'{item["role"]}: {item["content"]}\n' for item in conversation]
    )

    response = openai.ChatCompletion.create(
        model="gpt-4-0314",
        # model="gpt-3.5-turbo-16k-0613",
        messages=conversation,
        temperature=1,
        max_tokens=1000,
        top_p=1,
        frequency_penalty=0,
        presence_penalty=0,
    )

    # Extract the generated response from the API's response
    generated_text = response["choices"][0]["message"]["content"]

    # Return the response
    return generated_text
