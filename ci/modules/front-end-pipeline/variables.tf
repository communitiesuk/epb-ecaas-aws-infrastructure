
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

variable "github_branch" {
  type = string
}

variable "github_organisation" {
  type = string
}

variable "github_repository" {
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

variable "sentry_auth_token" {
  type      = string
  sensitive = true
}