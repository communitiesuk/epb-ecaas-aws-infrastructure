variable "codepipeline_bucket_arn" {
  type = string
}

variable "codestar_connection_arn" {
  type = string
}

variable "cross_account_role_arns" {
  type = list(string)
}

variable "region" {
  type = string
}

variable "s3_buckets_to_access" {
  type = list(string)
}

variable "api_integration_terraform_state_bucket" {
  type = string
}

variable "api_tfstate" {
  type = string
}
