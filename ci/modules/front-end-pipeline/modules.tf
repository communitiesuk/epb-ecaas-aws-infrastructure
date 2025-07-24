module "codebuild_check_front_end" {
  source                     = "../codebuild_project"
  codebuild_role_arn         = var.codebuild_role_arn
  name                       = "${var.project_name}-codebuild-check-front-end"
  codebuild_compute_type     = "BUILD_GENERAL1_MEDIUM"
  codebuild_environment_type = "LINUX_CONTAINER"
  build_image_uri            = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
  buildspec_file             = "buildspec/check_front_end.yml"
  region                     = var.region
  environment_variables      = []
}

module "codebuild_build_front_end" {
  source                     = "../codebuild_project"
  codebuild_role_arn         = var.codebuild_role_arn
  name                       = "${var.project_name}-codebuild-build-front-end"
  codebuild_compute_type     = "BUILD_GENERAL1_LARGE"
  codebuild_environment_type = "LINUX_CONTAINER"
  build_image_uri            = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
  buildspec_file             = "buildspec/build_front_end.yml"
  environment_variables = [
    { name = "AWS_DEFAULT_REGION", value = var.region },
    { name = "AWS_ACCOUNT_ID", value = var.account_ids["integration"] },
    { name = "SENTRY_DSN", type = "PARAMETER_STORE", value = "SENTRY_DSN" },
    { name = "BUILD_FOR_AWS_LAMBDA", value = "1" },
    { name = "SENTRY_AUTH_TOKEN", value = var.sentry_auth_token }
  ]
  region = var.region
}

module "codebuild_deploy_front_end" {
  source                     = "../codebuild_project"
  codebuild_role_arn         = var.codebuild_role_arn
  name                       = "${var.project_name}-codebuild-deploy-front-end"
  codebuild_compute_type     = "BUILD_GENERAL1_LARGE"
  codebuild_environment_type = "LINUX_CONTAINER"
  build_image_uri            = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
  buildspec_file             = "buildspec/deploy_front_end.yml"
  environment_variables = [
    { name = "AWS_DEFAULT_REGION", value = var.region },
    { name = "AWS_ACCOUNT_ID", value = var.account_ids["integration"] },
    { name = "SENTRY_DSN", type = "PARAMETER_STORE", value = "SENTRY_DSN" }
  ]
  region = var.region
}

module "codebuild_e2e_test_front_end" {
  source                     = "../codebuild_project"
  codebuild_role_arn         = var.codebuild_role_arn
  name                       = "${var.project_name}-codebuild-e2e_test-front-end"
  codebuild_compute_type     = "BUILD_GENERAL1_MEDIUM"
  codebuild_environment_type = "LINUX_CONTAINER"
  build_image_uri            = "mcr.microsoft.com/playwright:v1.54.0-noble"
  buildspec_file             = "buildspec/e2e_test_front_end.yml"
  region                     = var.region
  environment_variables = [
    { name = "ECAAS_URL", value = var.ecaas_url },
  ]
}
