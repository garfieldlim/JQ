import openai
from config import OPENAI_API_KEY


def generate_response(prompt, string_json):
    # Format the input as per the desired conversation format
    openai.api_key = OPENAI_API_KEY
    print(f"Prompt: {prompt}.")

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
        model="gpt-4",
        messages=conversation,
        temperature=1,
        max_tokens=1000,
        top_p=1,
        frequency_penalty=0,
        presence_penalty=0,
    )

    # Extract the generated response from the API's response
    generated_text = response["choices"][0]["message"]["content"]
    print("This is generated text, ", generated_text)
    # Return the response
    return generated_text
