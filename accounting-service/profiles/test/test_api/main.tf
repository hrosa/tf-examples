module "datastore" {
  source = "../../../modules/data-store"
  record_types = local.record_types
}

module "producer" {
  depends_on = [module.datastore]
  source     = "../../../modules/api"

  api_name = "accounting"
  api_body = ""
}