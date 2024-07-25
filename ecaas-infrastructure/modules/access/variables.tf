variable "ci_account_id" {
  type = string
}

variable "integration_terraform_state_bucket" {
  type = string
}

variable "api_tfstate" {
  type = string
}

variable "integration_terraform_state_table_arn" {
  type = string
}

variable "hem_lambda_arn" {
  type = string
}

variable "integration_aws_lambda_role" {
  type = string
}

variable "integration_cargo_lambda_role" {
  type = string
}