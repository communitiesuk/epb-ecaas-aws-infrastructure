variable "log_group_retention_in_days" {
  default = 14
  type    = number
}

variable "environment" {
  type = string
}

variable "invoking_role_name" {
  type        = string
  description = "The IAM role name of the caller lambda (hem-lambda) that needs to invoke the BREL PDF generator lambda"
}

variable "ci_account_id" {
  type        = string
  description = "AWS Account ID for the CI server"
}