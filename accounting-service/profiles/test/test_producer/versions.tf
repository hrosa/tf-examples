terraform {
  required_version = "1.3.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.53.0"
    }
  }

  backend "local" {
    path = "accounting-service-producer.tfstate"
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "accesskey"
  secret_key = "secretkey"

  max_retries       = 1
  s3_use_path_style = true

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    cloudwatchlogs = local.localstack_endpoint
    elasticsearch  = local.localstack_endpoint
    firehose       = local.localstack_endpoint
    iam            = local.localstack_endpoint
    s3             = local.localstack_endpoint
    sts            = local.localstack_endpoint
  }
}

