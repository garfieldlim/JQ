import json
from pymilvus import (
    connections,
)
from jq_admin.lib.newflask.database import (
    populate_results,
    search_collections,
    sort_results,
)

from embeddings import vectorize_query
from openai import generate_response


def question_answer():
    while True:
        try:
            prompt = input("You: ")
            if not prompt:
                print("No input provided. Try again.")
                continue
            vectors = vectorize_query(prompt)
            if vectors is None:
                print("No vectors returned. Check your vectorize_query function.")
                continue
            ranked_partitions = ranked_partitions(vectors)
            if ranked_partitions is None:
                print(
                    "No ranked_partitions returned. Check your ranking_partitions function."
                )
                continue
            print(f"Ranked partitions: {ranked_partitions}")
            partition = 0
            correct = 0
            while correct != 1:
                results_dict = search_collections(
                    vectors, [ranked_partitions[partition]]
                )
                if results_dict is None:
                    print(
                        "No results returned. Check your search_collections function."
                    )
                    break
                json_results_sorted = sort_results(results_dict)
                if json_results_sorted is None:
                    print(
                        "No sorted results returned. Check your process_results function."
                    )
                    break
                final_results = populate_results(
                    json_results_sorted, ranked_partitions[partition]
                )
                if final_results is None:
                    print(
                        "No final results returned. Check your populate_results function."
                    )
                    break
                string_json = json.dumps(final_results)
                generated_text = generate_response(prompt, string_json)
                if generated_text is None:
                    print(
                        "No response generated. Check your generate_response function."
                    )
                    break
                print(f"JQ: {generated_text}")
                correct = input("Is the answer correct? 1-Y, 0-N: ")
                if correct not in ["0", "1"]:
                    print("Invalid input. Try again.")
                elif partition <= 3:
                    partition = partition + 1
                else:
                    partition = 0
        except Exception as e:
            print(f"An error occurred: {e}")
