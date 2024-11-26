resource "aws_cognito_user_pool" "pool" {
  name = "ecaas-user-pool"
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain          = "auth.${var.domain_name}"
  certificate_arn = var.cdn_certificate_arn
  user_pool_id    = aws_cognito_user_pool.pool.id
}

resource "aws_api_gateway_authorizer" "gateway_authorizer" {
  name          = "gateway-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.ECaaSAPI.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.pool.arn]
}

resource "aws_cognito_user_pool_client" "client" {
  name                                 = "client"
  user_pool_id                         = aws_cognito_user_pool.pool.id
  generate_secret                      = true
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_CUSTOM_AUTH", "ALLOW_USER_SRP_AUTH"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = ["ecaas-api/home-energy-model"]
}

resource "aws_cognito_resource_server" "resource" {
  identifier = "ecaas-api"
  name       = "ecaas-api"

  scope {
    scope_name        = "home-energy-model"
    scope_description = "access to home energy model api endpoint"
  }

  user_pool_id = aws_cognito_user_pool.pool.id
}