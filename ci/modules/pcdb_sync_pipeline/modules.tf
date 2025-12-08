module "codebuild_build_lambda" {
  source                     = "../codebuild_project"
  codebuild_role_arn         = var.codebuild_role_arn
  name                       = "${var.project_name}-codebuild-build-lambda"
  codebuild_compute_type     = "BUILD_GENERAL1_LARGE"
  codebuild_environment_type = "LINUX_CONTAINER"
  build_image_uri            = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
  buildspec_file             = "buildspec/build_lambda.yml"
  environment_variables = [
    { name = "AWS_DEFAULT_REGION", value = var.region },
    { name = "AWS_ACCOUNT_ID", value = var.account_ids["integration"] },
  ]
  region = var.region
}

module "codebuild_deploy_lambda" {
  source                     = "../codebuild_project"
  codebuild_role_arn         = var.codebuild_role_arn
  name                       = "${var.project_name}-codebuild-deploy-lambda"
  codebuild_compute_type     = "BUILD_GENERAL1_LARGE"
  codebuild_environment_type = "LINUX_CONTAINER"
  build_image_uri            = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
  buildspec_file             = "buildspec/deploy_lambda.yml"
  environment_variables = [
    { name = "AWS_DEFAULT_REGION", value = var.region },
    { name = "AWS_ACCOUNT_ID", value = var.account_ids["integration"] },
  ]
  region = var.region
}