# PROFILE
variable "aws_account" {
  type = string
}

# DEPENDENCIES
variable "lambda_auth_path" {
  type = string
}

variable "lambda_query_path" {
  type = string
}

# ACCOUNTING SERVICE
variable "record_types" {
  type = set(string)
}

# API GATEWAY
variable "api_name" {
  type = string
}

variable "api_version" {
  type = string
  default = "1.0.0"
}

variable "api_description" {
  type = string
  default = "API generated with Terraform"
}

# ELASTIC SEARCH
variable "elasticsearch_endpoint" {
  type = string
}