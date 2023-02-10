locals {
  api_root = "/accounting"
  templates_vlt = "${path.module}/resources/velocity"
  templates_openapi = "${path.module}/resources/openapi"
  templates_by_type = transpose({
    for item in var.record_types : item =>fileset(local.templates_openapi, "api-${item}*.tpl")
  })
}

