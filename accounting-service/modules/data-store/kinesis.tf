resource "aws_kinesis_firehose_delivery_stream" "datastore" {
  for_each = var.record_types

  name        = "accounting-datastore-${each.key}"
  destination = "elasticsearch"

  kinesis_source_configuration {
    kinesis_stream_arn = var.kinesis_broker_arn
    role_arn           = aws_iam_role.firehose.arn
  }

  elasticsearch_configuration {
    cluster_endpoint = aws_opensearch_domain.accounting.id
    index_name = each.key
    role_arn   = aws_iam_role.elasticsearch.arn
  }
}