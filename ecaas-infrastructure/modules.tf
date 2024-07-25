module "access" {
  source                                = "./modules/access"
  ci_account_id                         = var.ci_account_id
  integration_terraform_state_bucket    = var.integration_terraform_state_bucket
  api_tfstate                           = var.api_tfstate
  integration_terraform_state_table_arn = var.integration_terraform_state_table_arn
  hem_lambda_arn = var.hem_lambda_arn
  integration_aws_lambda_role = var.integration_aws_lambda_role
  integration_cargo_lambda_role = var.integration_cargo_lambda_role
}
