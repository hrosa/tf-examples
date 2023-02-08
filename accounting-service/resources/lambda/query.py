import json
import os
import urllib.request


def lambda_handler(event, context):
    # Read env variables
    index_name = os.environ["INDEX_NAME"]
    es_endpoint = os.environ['ES_ENDPOINT']

    # Use path params as query filters
    # Root endpoints will return all records from the index
    # value_when_true if condition else value_when_false
    path_params = event.get('pathParameters', {}) if event else {}
    if path_params:
        query = {"query": {"bool": {"must": []}}}
        for key, value in path_params.items():
            query["query"]["bool"]["must"].append({"match": {key: value}})
    else:
        query = {"query": {"match_all": {}}}

    # Submit query
    req = urllib.request.Request(url="http://" + es_endpoint + "/" + index_name + "/_search?pretty",
                                 method="POST",
                                 data=json.dumps(query).encode("utf-8"),
                                 headers={"Content-Type": "application/json"})
    response = urllib.request.urlopen(req)
    response_data = response.read().decode("utf-8")

    # Return results
    return {
        "statusCode": 200,
        "body": response_data,
        "query": json.dumps(query),
        "event": event
    }
