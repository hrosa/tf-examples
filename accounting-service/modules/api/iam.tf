# LAMBDA - AUTH
resource "aws_iam_role" "lambda-api-auth" {
  assume_role_policy = jsonencode({})
  # TODO API auth role
}


# LAMBDA - QUERY
resource "aws_iam_role" "lambda-query" {
  assume_role_policy = jsonencode({})
  # TODO API auth role
}