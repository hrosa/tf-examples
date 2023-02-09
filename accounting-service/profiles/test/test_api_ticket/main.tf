module "datastore" {
  source       = "../../../modules/datastore"
  record_types = local.record_types
  aws_account  = local.aws_account
}

module "api" {
  depends_on = [module.datastore]
  source     = "../../../modules/api"

  aws_account = local.aws_account

  record_types = local.record_types
  api_name     = "accounting_tickets"

  elasticsearch_endpoint = module.datastore.datastore_endpoint

  lambda_auth_path  = data.archive_file.auth_lambda.output_path
  lambda_query_path = data.archive_file.query_lambda.output_path
}