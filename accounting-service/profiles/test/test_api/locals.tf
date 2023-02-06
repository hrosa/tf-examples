locals {
  # AWS PROFILE
  aws_account_id = "000000000000"
  aws_profile    = "ci"

  # LOCAL STACK
  localstack_endpoint = "http://localhost:4566"

  # API GW
  api_root = "/store/accounting/"

  record_types = toset(["purchase", "repair"])

  templates_openapi = "${path.module}/templates/openapi"
  templates_by_type = transpose({for item in local.record_types : item => fileset(local.templates_openapi, "api-${item}-*.tpl")})
}