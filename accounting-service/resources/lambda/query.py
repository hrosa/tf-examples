import boto3
import json
import os


def lambda_handler(event, context):
    opensearch = boto3.client("opensearch")

    index_name = os.environ["INDEX_NAME"]

    # Get the search query, from_date, and to_date from the query string parameters
    query = event.get("queryStringParameters", {}).get("query", "")
    from_date = event.get("queryStringParameters", {}).get("from_date", "")
    to_date = event.get("queryStringParameters", {}).get("to_date", "")

    # If the query is missing, return a Bad Request response
    if not query:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing 'query' parameter"})
        }

    # If either from_date or to_date is missing, don't include filtering in the query
    if from_date and to_date:
        query = f"{query} record_date: [{from_date} TO {to_date}]"

    response = opensearch.search(
        indexName=index_name,
        query=query,
    )

    print(json.dumps(response, indent=2))

    return {
        "statusCode": 200,
        "body": json.dumps(response)
    }
