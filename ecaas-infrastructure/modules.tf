module "access" {
  source               = "./modules/access"
  ci_account_id        = var.ci_account_id
  hem_lambda_arn       = module.api_gateway.hem_lambda_arn
  front_end_lambda_arn = module.front_end.front_end_lambda_arn
  front_end_s3_arn     = module.front_end.front_end_s3_arn
}

module "api_gateway" {
  source              = "./modules/api_gateway"
  region              = var.region
  cdn_certificate_arn = module.cdn_certificate.certificate_arn
  domain_name         = var.domain_name
}

# This being on us-east-1 is a requirement for CloudFront to use the SSL certificate
module "cdn_certificate" {
  source = "./modules/ssl"
  providers = {
    aws = aws.us-east
  }
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
}

module "front_end" {
  source                          = "./modules/front_end"
  front_end_s3_bucket_name        = "epb-ecaas-front-end-s3-bucket"
  ecaas_auth_api_url              = var.ecaas_auth_api_url
  ecaas_api_url                   = var.ecaas_api_url
  cognito_user_pool_id            = var.cognito_user_pool_id
  nuxt_session_password           = var.nuxt_session_password
  nuxt_oauth_cognito_redirect_url = var.nuxt_oauth_cognito_redirect_url
  sentry_auth_token               = var.sentry_auth_token
  sentry_dsn                      = var.sentry_dsn
  sentry_config                   = var.sentry_config
}

module "parameter_store" {
  source = "./modules/parameter_store"
  parameters = {
    "client_id" : {
      type  = "SecureString"
      value = var.parameters["client_id"]
    }
    "client_secret" : {
      type  = "SecureString"
      value = var.parameters["client_secret"]
    }
    "nuxt_oauth_cognito_client_id" : {
      type  = "SecureString"
      value = var.parameters["nuxt_oauth_cognito_client_id"]
    }
    "nuxt_oauth_cognito_client_secret" : {
      type  = "SecureString"
      value = var.parameters["nuxt_oauth_cognito_client_secret"]
    }
    "epc_team_main_slack_url" : {
      type  = "SecureString"
      value = var.parameters["epc_team_main_slack_url"]
    }
    "epb_team_slack_url" : {
      type  = "SecureString"
      value = var.parameters["epb_team_slack_url"]
    }
    # "stage" : {
    #   type  = "String"
    #   value = var.parameters["stage"]
    # }
  }
}

module "logging" {
  source = "./modules/logging"
  region = var.region
}

module "alerts" {
  source = "./modules/alerts"
  region = var.region
  # environment                = var.parameters["STAGE"]
  slack_webhook_url         = var.parameters["epb_team_slack_url"]
  main_slack_alerts         = var.environment == "ecaas-integration" ? 1 : 0
  main_slack_webhook_url    = var.parameters["epc_team_main_slack_url"]
  cloudtrail_log_group_name = module.logging.cloudtrail_log_group_name
}
