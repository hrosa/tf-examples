import datetime
import json
import os
import urllib.request


def lambda_handler(event, context):
    # Get environment data
    index_name = os.environ["INDEX_NAME"]
    es_endpoint = os.environ['ES_ENDPOINT']

    # Get the search query, from_date, and to_date from the query string parameters
    # from_date = event.get("queryStringParameters", {}).get("from_date", datetime.datetime.today())
    # to_date = event.get("queryStringParameters", {}).get("to_date", datetime.datetime.now())

    query = json.dumps({"query": {"match_all": {}}})

    # If either from_date or to_date is missing, don't include filtering in the query
    # if from_date and to_date:
    #     query = {
    #         "query": {
    #             "bool": {
    #                 "filter": [
    #                     {
    #                         "range": {
    #                             "date_created": {
    #                                 "gte": from_date,
    #                                 "lte": to_date
    #                             }
    #                         }
    #                     }
    #                 ]
    #             }
    #
    #     }

    print("endpoint:" + es_endpoint + ", query: " + json.dumps(query))

    req = urllib.request.Request(url="http://" + es_endpoint + "/" + index_name + "/_search?pretty",
                                 method="POST",
                                 data=query.encode("utf-8"),
                                 headers={"Content-Type": "application/json"})
    response = urllib.request.urlopen(req)
    response_data = response.read().decode("utf-8")

    print(response_data)

    return {
        "statusCode": 200,
        "body": response_data
    }
