# KINESIS AGENT
resource "aws_iam_role" "producer" {
  assume_role_policy = jsonencode({

  })
  # TODO write producer IAM role
}

# FIREHOSE
resource "aws_iam_role" "firehose" {
  assume_role_policy = jsonencode({

  })
  # TODO Firehose role
}