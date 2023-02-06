# FIREHOSE
resource "aws_iam_role" "firehose" {
  assume_role_policy = jsonencode({

  })
  # TODO Firehose role
}

# ELASTIC SEARCH
resource "aws_iam_role" "elasticsearch" {
  assume_role_policy = jsonencode({})
  # TODO ElasticSearch role
}