resource "aws_api_gateway_rest_api" "api" {
  name = var.api_name
  body = templatefile("${local.templates_openapi}/apigw-body.tpl",
    {
      api_name             = var.api_name
      authorizer_name      = aws_lambda_function.accounting-query.function_name
      authorizer_arn       = aws_lambda_function.accounting-query.arn
      endpoint_definitions = join(",", [for item in values(data.template_file.endpoint_definitions) : item.rendered]),
    })

  put_rest_api_mode = "merge"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}