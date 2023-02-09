data "archive_file" "auth_lambda" {
  source_file = "${path.module}/../../../resources/lambda/authorizer.py"
  output_path = "${path.module}/target/lambda/authorizer.zip"
  type        = "zip"
}

data "archive_file" "query_lambda" {
  source_file = "${path.module}/../../../resources/lambda/query.py"
  output_path = "${path.module}/target/lambda/query.zip"
  type        = "zip"
}