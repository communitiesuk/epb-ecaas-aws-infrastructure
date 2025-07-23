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
  source                  = "./modules/ecaas_api_codebuild_role"
  codepipeline_bucket_arn = module.artefact.codepipeline_bucket_arn
  cross_account_role_arns = var.cross_account_role_arns
  codestar_connection_arn = module.codestar_connection.codestar_connection_arn
  region                  = var.region
  s3_buckets_to_access    = [var.tech_docs_bucket_name]
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

module "tech_docs_pipeline" {
  artefact_bucket         = module.artefact.codepipeline_bucket
  codebuild_role_arn      = module.codebuild_role.aws_codebuild_role_arn
  codepipeline_role_arn   = module.codepipeline_role.aws_codepipeline_role_arn
  codestar_connection_arn = module.codestar_connection.codestar_connection_arn
  github_branch           = "main"
  github_repository       = "epb-ecaas-tech-docs"
  github_organisation     = var.github_organisation
  region                  = var.region
  repo_bucket_name        = var.tech_docs_bucket_name
  source                  = "./modules/tech-docs-pipeline"
  dev_account_id          = var.account_ids["integration"]
}

module "front-end-pipeline" {
  source                  = "./modules/front-end-pipeline"
  codepipeline_bucket     = module.artefact.codepipeline_bucket
  codepipeline_role_arn   = module.codepipeline_role.aws_codepipeline_role_arn
  codebuild_role_arn      = module.codebuild_role.aws_codebuild_role_arn
  pipeline_name           = "ecaas-frontend-pipeline"
  github_repository       = "epb-ecaas-frontend"
  github_branch           = "main"
  github_organisation     = var.github_organisation
  codestar_connection_arn = module.codestar_connection.codestar_connection_arn
  project_name            = "epb-ecaas-frontend"
  # codebuild_image_ecr_url = var.codebuild_image_ecr_url
  region                  = var.region
  account_ids             = var.account_ids
  sentry_auth_token       = var.sentry_auth_token
  ecaas_url = var.ecaas_url
}

module "tech_docs" {
  source                = "./modules/tech_docs"
  region                = var.region
  tech_docs_bucket_name = var.tech_docs_bucket_name
}

module "parameters" {
  source = "./modules/parameter_store"
  parameters = {
    "SENTRY_DSN" : {
      type  = "String"
      value = var.sentry_dsn
    },
    "LOGIN_USERNAME" : {
      type  = "String"
      value = var.login_username
    },
    "LOGIN_PASSWORD" : {
      type  = "String"
      value = var.login_password
    }
  }
}