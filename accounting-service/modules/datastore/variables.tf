# PROFILE
variable "aws_account" {
  type = string
}

# ACCOUNTING SERVICE
variable "record_types" {
  type = set(string)
}