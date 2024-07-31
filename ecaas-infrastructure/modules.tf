module "access" {
  source                                = "./modules/access"
  ci_account_id                         = var.ci_account_id
  integration_terraform_state_bucket    = var.integration_terraform_state_bucket
  integration_terraform_state_table_arn = var.integration_terraform_state_table_arn
  integration_hem_lambda_arn            = var.integration_hem_lambda_arn
  integration_aws_lambda_role           = var.integration_aws_lambda_role
  integration_cargo_lambda_role         = var.integration_cargo_lambda_role
}

module "api_gateway" {
  source = "./modules/api_gateway"
}
