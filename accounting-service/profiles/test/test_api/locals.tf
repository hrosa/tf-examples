locals {
  # AWS PROFILE
  aws_account_id = "000000000000"
  aws_profile    = "ci"

  # LOCAL STACK
  localstack_endpoint = "http://localhost:4566"

  # API GW
  api_root = "/store/accounting/"

  record_types = toset(["purchase", "repair"])
}