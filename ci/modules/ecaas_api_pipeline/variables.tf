variable "codebuild_image_ecr_url" {
  type = string
}

variable "codebuild_role_arn" {
  type = string
}

variable "codepipeline_role_arn" {
  type = string
}

variable "codepipeline_bucket" {
  type = string
}

variable "codestar_connection_arn" {
  type = string
}

# these are for branch names in HEM libraries
variable "github_branch_main" {
  type = string
}

variable "github_branch_production" {
  type = string
}

# these are for the API lambdas
variable "github_lambda_branch_integration" {
  type = string
}

variable "github_lambda_branch_production" {
  type = string
}

variable "github_organisation" {
  type = string
}

variable "github_repository" {
  type = string
}

variable "hem_core_repository" {
  type = string
}

variable "fhs_wrapper_repository" {
  type = string
}

variable "pipeline_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "account_ids" {
  type = map(string)
}