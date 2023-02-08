output "datastore_arn" {
  value = aws_elasticsearch_domain.accounting.arn
}

output "datastore_domain" {
  value = aws_elasticsearch_domain.accounting.domain_name
}

output "datastore_endpoint" {
  value = aws_elasticsearch_domain.accounting.endpoint
}

output "s3_bucket_backup_arn" {
  value = aws_s3_bucket.backup.arn
}