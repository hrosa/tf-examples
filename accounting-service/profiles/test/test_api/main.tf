module "datastore" {
  source       = "../../../modules/datastore"
  record_types = local.record_types
}

module "producer" {
  depends_on = [module.datastore]
  source     = "../../../modules/api"

  record_types = local.record_types

  api_name = "accounting"
}