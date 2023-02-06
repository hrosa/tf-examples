locals {
  templates_openapi = "${path.module}/templates/openapi"
  templates_by_type = transpose({
    for item in var.record_types : item =>fileset(local.templates_openapi, "api-${item}*.tpl")
  })
}

