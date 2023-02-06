# AUTHORIZER
resource "aws_lambda_function" "api-auth" {
  function_name = "accounting-auth"
  role          = aws_iam_role.lambda-api-auth.arn

  filename         = "${path.module}/resources/lambda/authorizer.py"
  handler          = "lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/resources/lambda/authorizer.py")

  runtime = "python3.9"
}

# OPENSEARCH QUERY
resource "aws_lambda_function" "accounting-query" {
  for_each = var.record_types
  function_name = "accounting-query"
  role          = aws_iam_role.lambda-api-auth.arn

  filename         = "${path.module}/resources/lambda/query.py"
  handler          = "lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/resources/lambda/query.py")

  runtime = "python3.9"

  environment {
    variables = {
      record_type = each.key
    }
  }
}