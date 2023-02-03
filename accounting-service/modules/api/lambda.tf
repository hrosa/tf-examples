# AUTHORIZER
resource "aws_lambda_function" "api-auth" {
  function_name = "accoubting-auth"
  role          = aws_iam_role.lambda-api-auth.arn
}

# OPENSEARCH QUERY
resource "aws_lambda_function" "accounting-query" {
  function_name = "accoubting-query"
  role          = aws_iam_role.lambda-api-auth.arn
}