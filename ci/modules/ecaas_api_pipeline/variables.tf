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

variable "github_branch" {
  type = string
}

variable "github_branch_production" {
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

variable "hem_core_branch" {
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