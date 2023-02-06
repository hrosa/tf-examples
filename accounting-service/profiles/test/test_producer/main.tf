module "datastore" {
  source = "../../../modules/datastore"
  record_types = local.record_types
}

module "producer" {
  source     = "../../../modules/producer"
  depends_on = [module.datastore]

  record_types       = local.record_types
  datastore_endpoint = module.datastore.datastore_endpoint
}