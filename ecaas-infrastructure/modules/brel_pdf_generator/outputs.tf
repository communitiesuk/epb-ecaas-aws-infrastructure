output "brel_pdf_generator_lambda_arn" {
  value       = aws_lambda_function.brel_pdf_generator_lambda.arn
  description = "The ARN of the BREL PDF Generator Lambda"
}