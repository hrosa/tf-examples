resource "aws_api_gateway_rest_api" "api" {
  name = var.api_name
  body = templatefile("${local.templates_openapi}/api-body.tpl",
    {
      api_name        = var.api_name
      api_version     = var.api_version
      api_description = var.api_description

      authorizer_name = aws_lambda_function.api-auth.function_name
      authorizer_arn  = aws_lambda_function.api-auth.arn

      api_paths = join(",", [
        for item in values(data.template_file.api_path_specifications) :item.rendered
      ]),
    })

  put_rest_api_mode = "merge"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}