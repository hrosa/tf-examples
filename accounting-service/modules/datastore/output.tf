output "datastore_endpoint" {
  value = aws_elasticsearch_domain.accounting.arn
}

output "s3_bucket_backup_arn" {
  value = aws_s3_bucket.backup.arn
}