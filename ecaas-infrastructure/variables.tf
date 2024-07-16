variable "region" {
  default = "eu-west-2"
  type    = string
}

variable "ci_account_id" {
  type = string
}

variable "api_integration_terraform_state_bucket" {
  type = string
}

variable "api_tfstate" {
  type = string
}

variable "integration_terraform_state_table_arn" {
  type = string
}