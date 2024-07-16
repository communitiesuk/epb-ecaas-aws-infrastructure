module "access" {
  source                                 = "./modules/access"
  ci_account_id                          = var.ci_account_id
  api_integration_terraform_state_bucket = var.api_integration_terraform_state_bucket
  api_tfstate                            = var.api_tfstate
  integration_terraform_state_table_arn  = var.integration_terraform_state_table_arn
}
