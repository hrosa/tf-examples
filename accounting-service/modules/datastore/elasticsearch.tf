resource "aws_elasticsearch_domain" "accounting" {
  domain_name           = "accounting"
  elasticsearch_version = "7.9"

  cluster_config {
    dedicated_master_enabled = true
    dedicated_master_type    = "m3.medium.elasticsearch"

    instance_type = "m3.medium.elasticsearch"

    warm_enabled = true
    warm_type    = "ultrawarm1.medium.elasticsearch"
  }

  access_policies = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Action : "es:*",
          Principal : "*",
          Effect : "Allow",
          Resource : "arn:aws:es:${data.aws_region.current.name}:${var.aws_account}:domain/accounting/*",
        }
      ]
    })
}