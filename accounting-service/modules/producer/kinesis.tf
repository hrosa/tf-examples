resource "aws_kinesis_stream" "broker" {
  name        = "accounting-broker"
  stream_mode_details = {
    stream_mode = "ON_DEMAND"
  }
}