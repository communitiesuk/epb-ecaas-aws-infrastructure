output "brel_pdf_generator_lambda_arn" {
  value       = aws_lambda_function.brel_pdf_generator_lambda.arn
  description = "The ARN of the BREL PDF Generator Lambda"
}

output "brel_pdf_generator_lambda_function_url" {
  description = "Function URL for the BREL PDF Generator Lambda"
  value       = aws_lambda_function_url.brel_pdf_generator_lambda_url.function_url
}

output "brel_pdf_generator_kms_key_arn" {
  value       = aws_kms_key.brel_pdf_generator.arn
  description = "The ARN of the KMS key for BREL PDF generator"
}

output "lambda_assets_s3_arn" {
  value = aws_s3_bucket.lambda_assets.arn
}

output "chromium_layer_arn" {
  value = aws_lambda_layer_version.chromium_layer.layer_arn
}