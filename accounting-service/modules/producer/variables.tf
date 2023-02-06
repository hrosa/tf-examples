# ACCOUNTING SERVICE
variable "record_types" {
  type = set(string)
}

# DATA STORE
variable "datastore_endpoint" {
  type = string
}

variable "s3_bucket_backup_arn" {
  type = string
}