output "front_end_lambda_arn" {
  value       = aws_lambda_function.front_end_lambda.arn
  description = "The ARN of the front end lambda"
}

output "front_end_s3_arn" {
  value       = aws_s3_bucket.frontend_s3.arn
  description = "The ARN of the S3 bucket for frontend assets"
}
