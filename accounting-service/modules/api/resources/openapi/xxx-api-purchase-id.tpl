"${api_root}/purchases/{purchaseId}": {
    "get": {
      "description": "Returns a specific purchase by ID",
      "parameters": [
        {
          "name": "purchaseId",
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
                  "itemName": {
                    "type": "string"
                  },
                  "quantity": {
                    "type": "integer",
                    "format": "int32"
                  },
                  "price": {
                    "type": "number",
                    "format": "float"
                  },
                  "dateCreated": {
                    "type": "string",
                    "format": "date-time"
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
      }
    }
  }
}