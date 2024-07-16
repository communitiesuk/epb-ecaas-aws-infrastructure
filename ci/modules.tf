module "artefact" {
  source = "./modules/artifact_bucket"
  region = var.region
}

module "codestar_connection" {
  source = "./modules/codestar_connection"
  region = var.region
}

module "codepipeline_role" {
  source = "./modules/codepipeline_role"
  region = var.region
}

module "cc-tray" {
  source = "./modules/cc_tray"
  region = var.region
}

module "codebuild_role" {
  source                                 = "./modules/ecaas_api_codebuild_role"
  codepipeline_bucket_arn                = module.artefact.codepipeline_bucket_arn
  cross_account_role_arns                = var.cross_account_role_arns
  codestar_connection_arn                = module.codestar_connection.codestar_connection_arn
  region                                 = var.region
  s3_buckets_to_access                   = [var.api_integration_terraform_state_bucket]
  api_integration_terraform_state_bucket = var.api_integration_terraform_state_bucket
  api_tfstate                            = var.api_tfstate
}

module "ecaas-api-pipeline" {
  source                  = "./modules/ecaas_api_pipeline"
  codepipeline_bucket     = module.artefact.codepipeline_bucket
  codepipeline_role_arn   = module.codepipeline_role.aws_codepipeline_role_arn
  codebuild_role_arn      = module.codebuild_role.aws_codebuild_role_arn
  pipeline_name           = "ecaas-api-pipeline"
  github_repository       = "epb-ecaas-api"
  github_branch           = "main"
  github_organisation     = var.github_organisation
  hem_lambda_repository   = "epb-home-energy-model"
  hem_lambda_branch       = "main"
  codestar_connection_arn = module.codestar_connection.codestar_connection_arn
  project_name            = "ecaas-api"
  codebuild_image_ecr_url = var.codebuild_image_ecr_url
  region                  = var.region
  account_ids             = var.account_ids
}
