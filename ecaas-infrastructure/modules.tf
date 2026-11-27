module "access" {
  source                         = "./modules/access"
  ci_account_id                  = var.ci_account_id
  fhs_lambda_arn                 = module.fhs_monolith_lambda.lambda_arn
  front_end_lambda_arn           = module.front_end.front_end_lambda_arn
  front_end_s3_arn               = module.front_end.front_end_s3_arn
  pcdb_sync_lambda_arn           = module.pcdb_sync.pcdb_sync_lambda_arn
  enable_brel_pdf_generator      = var.environment == "ecaas-intg"
  brel_pdf_generator_lambda_arn  = try(module.brel_pdf_generator[0].brel_pdf_generator_lambda_arn, null)
  brel_lambda_assets_s3_arn      = try(module.brel_pdf_generator[0].lambda_assets_s3_arn, null)
  chromium_layer_arn             = try(module.brel_pdf_generator[0].chromium_layer_arn, null)
  brel_pdf_generator_kms_key_arn = try(module.brel_pdf_generator[0].brel_pdf_generator_kms_key_arn, null)
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
  lambda_invoke_arn     = module.fhs_monolith_lambda.lambda_invoke_arn
  lambda_function_name  = module.fhs_monolith_lambda.lambda_function_name
}

module "fhs_monolith_lambda" {
  source               = "./modules/lambda"
  products_table_arn   = module.pcdb_sync.pcdb_sync_products_table_arn
  lambda_function_name = "hem-lambda"
  lambda_memory_size   = 8192
  environment          = var.environment

  providers = {
    aws = aws.home-region
  }

  environment_vars = {
    SENTRY_ENVIRONMENT = var.environment
  }
}

module "fhs_lambda" {
  source               = "./modules/lambda"
  products_table_arn   = module.pcdb_sync.pcdb_sync_products_table_arn
  lambda_function_name = "fhs-lambda"
  environment          = var.environment
  count                = var.environment == "ecaas-intg" ? 1 : 0

  providers = {
    aws = aws.home-region
  }

  environment_vars = {
    SENTRY_ENVIRONMENT = var.environment
    STEP_FUNCTION_ARN = module.hem_worker_step_function.state_machine_arn
  }
}

module "hem_worker_lambda" {
  source               = "./modules/lambda"
  lambda_function_name = "hem-worker"
  lambda_memory_size   = 3072
  environment          = var.environment
  count                = var.environment == "ecaas-intg" ? 1 : 0

  providers = {
    aws = aws.home-region
  }
}

module "hem_worker_step_function" {
  source = "./modules/step_function"
  worker_lambda_arn = module.hem_worker_lambda[0].lambda_arn
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
  products_table_arn    = module.pcdb_sync.pcdb_sync_products_table_arn
}

module "pcdb_sync" {
  source            = "./modules/pcdb_sync"
  environment       = var.environment
  bucket_name       = module.pcdb_sync.pcdb_sync_bucket_name
  export_filename   = var.pcdb_export_filename
  pcdb_api_url      = var.pcdb_api_url
  pcdb_api_username = var.pcdb_api_username
  pcdb_api_password = var.pcdb_api_password
}

module "brel_pdf_generator" {
  count              = var.environment == "ecaas-intg" ? 1 : 0
  source             = "./modules/brel_pdf_generator"
  environment        = var.environment
  invoking_role_name = module.fhs_monolith_lambda.lambda_role_name
  ci_account_id      = var.ci_account_id
}

moved {
  from = module.brel_pdf_generator
  to   = module.brel_pdf_generator[0]
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
  source                 = "./modules/alerts"
  region                 = var.region
  slack_webhook_url      = var.parameters["epb_team_slack_url"]
  main_slack_alerts      = var.environment == "ecaas-intg" ? 1 : 0
  main_slack_webhook_url = var.parameters["epc_team_main_slack_url"]
}

moved {
  from = module.api_gateway.aws_iam_role_policy_attachment.lambda_policy_attachment
  to   = module.fhs_monolith_lambda.aws_iam_role_policy_attachment.lambda_policy_attachment
}

moved {
  from = module.api_gateway.aws_iam_role_policy_attachment.lambda_logs
  to   = module.fhs_monolith_lambda.aws_iam_role_policy_attachment.lambda_logs
}

moved {
  from = module.api_gateway.aws_lambda_function.hem_lambda
  to   = module.fhs_monolith_lambda.aws_lambda_function.this
}

moved {
  from = module.api_gateway.aws_iam_role_policy_attachment.xray_tracing
  to   = module.fhs_monolith_lambda.aws_iam_role_policy_attachment.xray_tracing
}

moved {
  from = module.api_gateway.aws_iam_role.lambda_role
  to   = module.fhs_monolith_lambda.aws_iam_role.lambda_role
}

moved {
  from = module.api_gateway.aws_iam_policy.xray_tracing
  to   = module.fhs_monolith_lambda.aws_iam_policy.xray_tracing
}

moved {
  from = module.api_gateway.aws_iam_policy.lambda_logging
  to   = module.fhs_monolith_lambda.aws_iam_policy.lambda_logging
}

moved {
  from = module.api_gateway.aws_cloudwatch_log_group.hem_lambda_log_group
  to   = module.fhs_monolith_lambda.aws_cloudwatch_log_group.lambda_log_group
}

moved {
  from = module.api_gateway.aws_iam_policy.dynamodb_lambda_policy
  to   = module.fhs_monolith_lambda.aws_iam_policy.dynamodb_lambda_policy
}

moved {
  from = module.fhs_monolith_lambda.aws_iam_role_policy_attachment.lambda_policy_attachment
  to   = module.fhs_monolith_lambda.aws_iam_role_policy_attachment.lambda_policy_attachment[0]
}

moved {
  from = module.fhs_monolith_lambda.aws_iam_policy.dynamodb_lambda_policy
  to   = module.fhs_monolith_lambda.aws_iam_policy.dynamodb_lambda_policy[0]
}