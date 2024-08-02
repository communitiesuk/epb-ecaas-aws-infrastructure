output "hem_lambda_arn" {
  value       = aws_lambda_function.hem_lambda.arn
  description = "The arn of the HEM lambda"
}
