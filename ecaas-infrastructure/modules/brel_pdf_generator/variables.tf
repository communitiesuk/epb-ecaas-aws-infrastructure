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

variable "chromium_version" {
  type        = string
  default     = "v153.0.0"
  description = "Version of the Chromium layer zip stored in the lambda_assets S3 bucket"
}