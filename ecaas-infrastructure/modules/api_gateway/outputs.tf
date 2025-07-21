output "hem_lambda_arn" {
  value       = aws_lambda_function.hem_lambda.arn
  description = "The arn of the HEM lambda"
}

output "rest_api_id" {
  value = aws_api_gateway_rest_api.ecaas_api.id
  description = "The ID of the ECaaS API gateway"
}

output "ecaas_api_url" {
  value = "https://${aws_api_gateway_domain_name.ecaas_api_domain_name.domain_name}"

}