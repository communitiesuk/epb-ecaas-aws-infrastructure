data "aws_caller_identity" "current" {}

module "codebuild_run_api_gateway_terraform" {
  source             = "../codebuild_project"
  codebuild_role_arn = var.codebuild_role_arn
  name               = "${var.project_name}-codebuild-run-api-gateway-terraform"
  build_image_uri    = var.codebuild_image_ecr_url
  buildspec_file     = "buildspec/api_gateway.yml"
  environment_variables = [
    { name = "AWS_DEFAULT_REGION", value = var.region },
    { name = "AWS_ACCOUNT_ID", value = var.account_ids["integration"] },
  ]
  region = var.region
}

module "codebuild_test_hem_lambda" {
  source                     = "../codebuild_project"
  codebuild_role_arn         = var.codebuild_role_arn
  name                       = "${var.project_name}-codebuild-test-hem-lambda"
  codebuild_compute_type     = "BUILD_GENERAL1_LARGE"
  codebuild_environment_type = "ARM_CONTAINER"
  build_image_uri            = "aws/codebuild/amazonlinux2-aarch64-standard:3.0"
  buildspec_file             = "buildspec/test_hem_lambda.yml"
  environment_variables = [
    { name = "AWS_DEFAULT_REGION", value = var.region },
    { name = "AWS_ACCOUNT_ID", value = var.account_ids["integration"] },
    { name = "SENTRY_DSN", type = "PARAMETER_STORE", value = "SENTRY_DSN" }
  ]
  region = var.region
}

module "codebuild_build_hem_lambda" {
  source                     = "../codebuild_project"
  codebuild_role_arn         = var.codebuild_role_arn
  name                       = "${var.project_name}-codebuild-build-hem-lambda"
  codebuild_compute_type     = "BUILD_GENERAL1_LARGE"
  codebuild_environment_type = "ARM_CONTAINER"
  build_image_uri            = "aws/codebuild/amazonlinux2-aarch64-standard:3.0"
  buildspec_file             = "buildspec/build_hem_lambda.yml"
  environment_variables = [
    { name = "AWS_DEFAULT_REGION", value = var.region },
    { name = "AWS_ACCOUNT_ID", value = var.account_ids["integration"] },
    { name = "SENTRY_DSN", type = "PARAMETER_STORE", value = "SENTRY_DSN" }
  ]
  region = var.region
}

module "codebuild_deploy_hem_lambda" {
  source             = "../codebuild_project"
  codebuild_role_arn = var.codebuild_role_arn
  name               = "${var.project_name}-codebuild-deploy-hem-lambda"
  build_image_uri    = var.codebuild_image_ecr_url
  buildspec_file     = "buildspec/deploy_hem_lambda.yml"
  environment_variables = [
    { name = "AWS_DEFAULT_REGION", value = var.region },
    { name = "AWS_ACCOUNT_ID", value = var.account_ids["integration"] },
  ]
  region = var.region
}

module "codebuild_run_app_test" {
  source             = "../codebuild_project"
  codebuild_role_arn = var.codebuild_role_arn
  name               = "${var.project_name}-codebuild-run-app-test"
  build_image_uri    = var.codebuild_image_ecr_url
  buildspec_file     = "buildspec.yml"
  environment_variables = [
    { name = "AWS_DEFAULT_REGION", value = var.region },
    { name = "AWS_ACCOUNT_ID", value = var.account_ids["integration"] },
  ]
  region = var.region
}