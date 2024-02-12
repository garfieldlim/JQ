import openai
from config import OPENAI_API_KEY


def generate_response(prompt, string_json):
    # Format the input as per the desired conversation format
    openai.api_key_path = OPENAI_API_KEY

    print("PROMPT: ", prompt)
    # print("STRING JSON: ", string_json)
    conversation = [
        {
            "role": "system",
            "content": """You are Josenian Quiri. University of San Jose- Recoletos' general knowledge base assistant. Refer to yourself as JQ. If there are links in the input, include them in your response. Otherwise, official website: https://usjr.edu.ph, official Facebook page: https://www.facebook.com/usjr.official/ """,
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
        model="gpt-4-turbo-preview",
        # model="gpt-3.5-turbo-16k-0613",
        messages=conversation,
        temperature=1,
        max_tokens=2000,
        top_p=1,
        frequency_penalty=0,
        presence_penalty=0,
    )

    # Extract the generated response from the API's response
    generated_text = response["choices"][0]["message"]["content"]

    # Return the response
    return generated_text
