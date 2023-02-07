module "datastore" {
  source       = "../../../modules/datastore"
  record_types = local.record_types

  aws_account = local.aws_account_id
}

module "producer" {
  source     = "../../../modules/producer"
  depends_on = [module.datastore]

  record_types         = local.record_types
  datastore_arn        = module.datastore.datastore_arn
  s3_bucket_backup_arn = module.datastore.s3_bucket_backup_arn
}