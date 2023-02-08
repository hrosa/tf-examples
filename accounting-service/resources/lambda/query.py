import json
import os
import urllib.request


def lambda_handler(event, context):
    index_name = os.environ["INDEX_NAME"]
    es_endpoint = os.environ['ES_ENDPOINT']

    query = json.dumps({"query": {"match_all": {}}})
    req = urllib.request.Request(url="http://" + es_endpoint + "/" + index_name + "/_search?pretty",
                                 method="POST",
                                 data=query.encode("utf-8"),
                                 headers={"Content-Type": "application/json"})
    response = urllib.request.urlopen(req)
    response_data = response.read().decode("utf-8")

    return {
        "statusCode": 200,
        "body": response_data
    }
