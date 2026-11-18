output "brel_pdf_generator_lambda_arn" {
  value       = aws_lambda_function.brel_pdf_generator_lambda.arn
  description = "The ARN of the BREL PDF Generator Lambda"
}

output "brel_pdf_generator_lambda_function_url" {
  description = "Function URL for the BREL PDF Generator Lambda"
  value       = aws_lambda_function_url.brel_pdf_generator_lambda_url.function_url
}