resource "aws_api_gateway_rest_api" "accounting" {
  name = var.api_name
  body = templatefile("${local.templates_openapi}/api-body.tpl",
    {
      api_name        = var.api_name
      api_root        = local.api_root
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

resource "aws_api_gateway_deployment" "accounting" {
  rest_api_id = aws_api_gateway_rest_api.accounting.id
  triggers    = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.accounting.body))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "accounting_test" {
  stage_name    = "test"
  rest_api_id   = aws_api_gateway_rest_api.accounting.id
  deployment_id = aws_api_gateway_deployment.accounting.id
}