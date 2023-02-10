"${api_root}/purchases/{purchase_id}": {
  "get": {
    "description": "Returns a specific purchase by ID",
    "parameters": [
      {
        "name": "purchase_id",
        "in": "path",
        "required": true,
        "description": "ID of the purchase to retrieve",
        "schema": {
          "type": "integer",
          "format": "int64"
        }
      }
    ],
    "responses": {
      "200": {
        "description": "OK",
        "content": {
          "application/json": {
            "schema": {
              "type": "object",
              "properties": {
                "id": {
                  "type": "integer",
                  "format": "int64"
                },
                "date_created": {
                  "type": "string",
                  "format": "date-time"
                },
                "item_name": {
                  "type": "string"
                },
                "price": {
                  "type": "number",
                  "format": "float"
                },
                "currency": {
                  "type": "string"
                }
              }
            }
          }
        }
      },
      "400": {
        "description": "Bad Request"
      },
      "500": {
        "description": "Internal Server Error"
      }
    },
    "security" : [ {
      "${authorizer_name}" : [ ]
    } ],
    "x-amazon-apigateway-integration" : {
      "httpMethod" : "POST",
      "uri" : "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${lambda_arn}/invocations",
      "responses" : {
        ".*httpStatus\":400.*" : {
          "statusCode" : "400",
          "responseTemplates" : {
            "application/json" : "$input.json('$')",
          }
        },
        "default" : {
          "statusCode" : "200",
          "responseTemplates" : {
            "application/json" : "${response_single_vtl}",
          }
        },
        ".*httpStatus\":500.*" : {
          "statusCode" : "500",
          "responseTemplates" : {
            "application/json" : "$input.json('$')",
          }
        }
      },
      "requestTemplates" : {
      },
      "passthroughBehavior" : "when_no_match",
      "timeoutInMillis" : 15000,
      "type" : "aws"
    }
  }
}