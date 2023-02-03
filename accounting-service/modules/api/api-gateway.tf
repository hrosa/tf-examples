resource "aws_api_gateway_rest_api" "api" {
  name = var.api_name
  body = var.api_body

  put_rest_api_mode = "merge"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}