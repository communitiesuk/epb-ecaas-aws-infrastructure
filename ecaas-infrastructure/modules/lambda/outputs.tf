output "lambda_arn" {
  value       = aws_lambda_function.this.arn
  description = "The ARN of the lambda entry"
}

output "lambda_invoke_arn" {
  value       = aws_lambda_function.this.invoke_arn
  description = "The ARN for invoking this lambda entry"
}

output "lambda_role_name" {
  description = "Execution role name for lambda"
  value       = aws_iam_role.lambda_role.name
}

output "lambda_function_name" {
  value = aws_lambda_function.this.function_name
}