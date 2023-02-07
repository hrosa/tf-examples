resource "aws_kinesis_firehose_delivery_stream" "datastore" {
  for_each = var.record_types

  name        = "accounting-${each.key}"
  destination = "elasticsearch"

  elasticsearch_configuration {
    domain_arn     = var.datastore_arn
    index_name     = each.key
    role_arn       = aws_iam_role.firehose.arn
    s3_backup_mode = "FailedDocumentsOnly"
  }

  s3_configuration {
    role_arn           = aws_iam_role.firehose.arn
    bucket_arn         = var.s3_bucket_backup_arn
    compression_format = "GZIP"
  }
}