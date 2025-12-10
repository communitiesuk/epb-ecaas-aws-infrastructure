output "pcdb_sync_lambda_arn" {
  value       = aws_lambda_function.pcdb_sync_lambda.arn
  description = "The arn of the pcdb sync lambda"
}

output "pcdb_sync_products_table_arn" {
  value = aws_dynamodb_table.products_table.arn
  description = "The arn of the pcdb dynamodb table"
}