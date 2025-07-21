output "ecaas_auth_url" {
  value       = "https://${aws_cognito_user_pool_domain.user_pool_domain.domain}"
  description = "The auth URL for Cognito"
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.pool.id
  description = "The ID of the Cognito user pool"
}

output "gateway_authorizer_id" {
  value = aws_api_gateway_authorizer.gateway_authorizer.id
  description = "The ID of the Gateway Authorizer"
}
