module "access" {
  source         = "./modules/access"
  ci_account_id  = var.ci_account_id
  hem_lambda_arn = module.api_gateway.hem_lambda_arn
}

module "api_gateway" {
  source = "./modules/api_gateway"
}
