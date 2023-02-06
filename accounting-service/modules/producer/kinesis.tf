resource "aws_kinesis_firehose_delivery_stream" "datastore" {
  for_each = var.record_types

  name        = "accounting-${each.key}"
  destination = "elasticsearch"

  elasticsearch_configuration {
    cluster_endpoint = var.datastore_endpoint
    index_name = each.key
    role_arn   = aws_iam_role.firehose.arn
  }
}