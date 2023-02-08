# AUTHORIZER
resource "aws_lambda_function" "api-auth" {
  function_name = "accounting-auth"
  role          = aws_iam_role.lambda-api-auth.arn

  filename         = var.lambda_auth_path
  handler          = "authorizer.lambda_handler"
  source_code_hash = filebase64sha256(var.lambda_auth_path)

  runtime = "python3.9"
}

# OPENSEARCH QUERY
resource "aws_lambda_function" "accounting-query" {
  for_each = var.record_types
  function_name = "accounting-query"
  role          = aws_iam_role.lambda-api-auth.arn

  filename         = var.lambda_query_path
  handler          = "query.lambda_handler"
  source_code_hash = filebase64sha256(var.lambda_query_path)

  runtime = "python3.9"

  environment {
    variables = {
      INDEX_NAME = each.key
    }
  }
}