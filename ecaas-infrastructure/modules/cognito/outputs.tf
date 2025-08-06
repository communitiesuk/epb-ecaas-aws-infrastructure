output "ecaas_auth_url" {
  value       = "https://${aws_cognito_user_pool_domain.user_pool_domain.domain}"
  description = "The auth URL for Cognito"
}

output "cognito_user_pool_id" {
  value       = aws_cognito_user_pool.pool.id
  description = "The ID of the Cognito user pool"
}

output "gateway_authorizer_id" {
  value       = aws_api_gateway_authorizer.gateway_authorizer.id
  description = "The ID of the Gateway Authorizer"
}

output "frontend_api_client_id" {
  value       = aws_cognito_user_pool_client.frontend_api_client.id
  description = "The client ID of the App client used by frontend to call the API"

}

output "frontend_api_client_secret" {
  value       = aws_cognito_user_pool_client.frontend_api_client.client_secret
  description = "The client secret of the App client used by frontend to call the API"
  sensitive   = true
}

output "frontend_user_login_client_id" {
  value       = aws_cognito_user_pool_client.frontend_user_login_client.id
  description = "The client ID of the App client used by frontend to log in users"

}

output "frontend_user_login_client_secret" {
  value       = aws_cognito_user_pool_client.frontend_user_login_client.client_secret
  description = "The client secret of the App client used by frontend to log in users"
  sensitive   = true
}
