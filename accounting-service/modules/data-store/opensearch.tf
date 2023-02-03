resource "aws_opensearch_domain" "accounting" {
  domain_name    = "accounting"
  engine_version = "OpenSearch_2.3"

  cluster_config {
    instance_type = "r4.large.search"
  }

  access_policies = jsonencode(
  {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "es:*",
        "Principal" : "*",
        "Effect" : "Allow",
        "Resource" : "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/accounting/*",
      }
    ]
  })
}