module "codebuild_build_brel_pdf_generator_lambda" {
  source                     = "../codebuild_project"
  codebuild_role_arn         = var.codebuild_role_arn
  name                       = "${var.project_name}-codebuild-build-brel-pdf-generator-lambda"
  build_image_uri            = var.codebuild_image_ecr_url
  buildspec_file             = "buildspec/build_brel_pdf_generator_lambda.yml"
  codebuild_environment_type = "ARM_CONTAINER"
  environment_variables = [
    { name = "AWS_DEFAULT_REGION", value = var.region },
    { name = "AWS_ACCOUNT_ID", value = var.account_ids["integration"] },
  ]
  region                     = var.region
}

module "codebuild_deploy_brel_pdf_generator_lambda_integration" {
  source                     = "../codebuild_project"
  codebuild_role_arn         = var.codebuild_role_arn
  name                       = "${var.project_name}-codebuild-deploy-brel-pdf-generator-lambda-integration"
  build_image_uri            = var.codebuild_image_ecr_url
  buildspec_file             = "buildspec/deploy_brel_pdf_generator_lambda.yml"
  codebuild_environment_type = "ARM_CONTAINER"
  environment_variables = [
    { name = "AWS_DEFAULT_REGION", value = var.region },
    { name = "AWS_ACCOUNT_ID",     value = var.account_ids["integration"] },
  ]
  region = var.region
}