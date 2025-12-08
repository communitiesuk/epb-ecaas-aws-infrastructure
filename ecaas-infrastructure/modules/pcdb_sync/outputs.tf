output "pcdb_sync_lambda_arn" {
  value       = aws_lambda_function.pcdb_sync_lambda.arn
  description = "The arn of the pcdb sync lambda"
}
