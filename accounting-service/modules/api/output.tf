output "api_id" {
  value = aws_api_gateway_rest_api.accounting.id
}

output "api_stage_name" {
  value = aws_api_gateway_stage.accounting_test.stage_name
}