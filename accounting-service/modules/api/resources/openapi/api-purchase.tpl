"${api_root}/purchases": {
  "get": {
    "description": "Returns a list of all purchases",
    "responses": {
      "200": {
        "description": "OK",
        "content": {
          "application/json": {
            "schema": {
              "type": "array",
              "items": {
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
            "application/json" : "$input.json('$')",
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