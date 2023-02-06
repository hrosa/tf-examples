# PROFILE
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "template_file" "api_path_specifications" {
  for_each = local.templates_by_type
  template = file("${local.templates_openapi}/${each.key}")
  vars     = {
    aws_region = data.aws_region.current.id

    api_root        = local.api_root
    authorizer_name = "accounting-auth"
    lambda_arn      = aws_lambda_alias.sdr_query_latest[one(each.value)].arn

    request_template         = jsonencode(file("${local.templates_vlt}/api_request_mapper.vm"))
    response_template_list   = jsonencode(file("${local.templates_vlt}/api_request_subaccounts_mapper.vm"))
    response_template_single = jsonencode(file("${local.templates_vlt}/api_request_subaccounts_mapper.vm"))
  }
}