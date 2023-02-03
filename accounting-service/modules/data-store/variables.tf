# ACCOUNTING SERVICE
variable "record_types" {
  type = set(string)
}

# KINESIS BROKER
variable "kinesis_broker_arn" {
  type = string
}