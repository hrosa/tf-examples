# PROFILE
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "template_file" "api_path_specifications" {
  for_each = local.templates_by_type
  template = file("${local.templates_openapi}/${each.key}")
  vars     = {
    aws_region      = data.aws_region.current.id
    api_root        = "/store/accounting/"
    authorizer_name = "accounting-auth"
    lambda_arn      = aws_lambda_function.accounting-query[one(each.value)].arn
  }
}