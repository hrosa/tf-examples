locals {
  # AWS PROFILE
  aws_account = "000000000000"
  aws_profile    = "ci"

  # LOCAL STACK
  localstack_endpoint = "http://localhost:4566"

  # API GW
  record_types = toset(["ticket"])
}