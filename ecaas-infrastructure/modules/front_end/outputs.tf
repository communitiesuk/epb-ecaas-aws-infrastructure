output "front_end_lambda_arn" {
  value       = aws_lambda_function.front_end_lambda.arn
  description = "The arn of the front end lambda"
}
