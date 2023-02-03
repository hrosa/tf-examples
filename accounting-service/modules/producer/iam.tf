resource "aws_iam_role" "producer" {
  assume_role_policy = jsonencode({

  })
  # TODO write producer IAM role
}

resource "aws_iam_role_policy" "producer_write_to_broker" {
  role   = aws_iam_role.producer.id
  policy = jsonencode({

  })
  # TODO write producer policy
}