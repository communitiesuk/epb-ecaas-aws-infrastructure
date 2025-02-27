module "codebuild_build_front_end" {
  source                     = "../codebuild_project"
  codebuild_role_arn         = var.codebuild_role_arn
  name                       = "${var.project_name}-codebuild-build-front-end"
  codebuild_compute_type     = "BUILD_GENERAL1_LARGE"
  codebuild_environment_type = "ARM_CONTAINER"
  build_image_uri            = "aws/codebuild/amazonlinux2-aarch64-standard:3.0"
  buildspec_file             = "buildspec/build_front_end.yml"
  environment_variables = [
    { name = "AWS_DEFAULT_REGION", value = var.region },
    { name = "AWS_ACCOUNT_ID", value = var.account_ids["integration"] },
    { name = "SENTRY_DSN", type = "PARAMETER_STORE", value = "SENTRY_DSN" }
  ]
  region = var.region
}