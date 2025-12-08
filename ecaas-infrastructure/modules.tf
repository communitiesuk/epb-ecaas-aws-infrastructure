module "access" {
  source               = "./modules/access"
  ci_account_id        = var.ci_account_id
  hem_lambda_arn       = module.api_gateway.hem_lambda_arn
  front_end_lambda_arn = module.front_end.front_end_lambda_arn
  front_end_s3_arn     = module.front_end.front_end_s3_arn
  pcdb_sync_lambda_arn = module.pcdb_sync.pcdb_sync_lambda_arn
}

module "cognito" {
  source                   = "./modules/cognito"
  domain_name              = var.api_domain_name
  cdn_certificate_arn      = module.api_cdn_certificate.certificate_arn
  rest_api_id              = module.api_gateway.rest_api_id
  frontend_callback_domain = var.frontend_domain_name
}

module "api_gateway" {
  source                = "./modules/api_gateway"
  region                = var.region
  domain_name           = var.api_domain_name
  cdn_certificate_arn   = module.api_cdn_certificate.certificate_arn
  gateway_authorizer_id = module.cognito.gateway_authorizer_id
  environment           = var.environment
}

# This being on us-east-1 is a requirement for CloudFront to use the SSL certificate
module "api_cdn_certificate" {
  source = "./modules/ssl"
  providers = {
    aws = aws.us-east
  }
  domain_name = var.api_domain_name
}

# This being on us-east-1 is a requirement for CloudFront to use the SSL certificate
module "frontend_cdn_certificate" {
  source = "./modules/ssl"
  providers = {
    aws = aws.us-east
  }
  domain_name = var.frontend_domain_name
}

module "front_end" {
  source                = "./modules/front_end"
  environment           = var.environment
  domain_name           = var.frontend_domain_name
  cdn_certificate_arn   = module.frontend_cdn_certificate.certificate_arn
  ecaas_api_url         = module.api_gateway.ecaas_api_url
  ecaas_auth_url        = module.cognito.ecaas_auth_url
  cognito_user_pool_id  = module.cognito.cognito_user_pool_id
  nuxt_session_password = var.nuxt_session_password
  sentry_auth_token     = var.sentry_auth_token
  sentry_dsn            = var.sentry_dsn
  gtag_id               = var.gtag_id
}

module "pcdb_sync" {
  source                = "./modules/pcdb_sync"
  environment           = var.environment
}

module "parameter_store" {
  source = "./modules/parameter_store"
  parameters = {
    "client_id" : {
      type  = "SecureString"
      value = module.cognito.frontend_api_client_id
    }
    "client_secret" : {
      type  = "SecureString"
      value = module.cognito.frontend_api_client_secret
    }
    "nuxt_oauth_cognito_client_id" : {
      type  = "SecureString"
      value = module.cognito.frontend_user_login_client_id
    }
    "nuxt_oauth_cognito_client_secret" : {
      type  = "SecureString"
      value = module.cognito.frontend_user_login_client_secret
    }
    "epc_team_main_slack_url" : {
      type  = "SecureString"
      value = var.parameters["epc_team_main_slack_url"]
    }
    "epb_team_slack_url" : {
      type  = "SecureString"
      value = var.parameters["epb_team_slack_url"]
    }
  }
}

module "logging" {
  source      = "./modules/logging"
  region      = var.region
  environment = var.environment
}

module "alerts" {
  source                    = "./modules/alerts"
  region                    = var.region
  slack_webhook_url         = var.parameters["epb_team_slack_url"]
  main_slack_alerts         = var.environment == "ecaas-intg" ? 1 : 0
  main_slack_webhook_url    = var.parameters["epc_team_main_slack_url"]
  cloudtrail_log_group_name = module.logging.cloudtrail_log_group_name
}
