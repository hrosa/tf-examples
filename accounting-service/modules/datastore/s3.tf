resource "aws_s3_bucket" "backup" {
  bucket = "${data.aws_region.current.name}-accounting-backup"
  acl    = "private"
}