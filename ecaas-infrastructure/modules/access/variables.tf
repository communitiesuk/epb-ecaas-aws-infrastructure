variable "ci_account_id" {
  type = string
}

variable "fhs_lambda_arn" {
  type = string
}

variable "front_end_lambda_arn" {
  type = string
}

variable "front_end_s3_arn" {
  type = string
}

variable "pcdb_sync_lambda_arn" {
  type = string
}

variable "brel_pdf_generator_lambda_arn" {
  type = string
}

variable "brel_pdf_generator_kms_key_arn" {
  type        = string
  default     = null
  description = "ARN of the KMS key used by the BREL PDF generator module"
}

variable "brel_lambda_assets_s3_arn" {
  type = string
}

variable "chromium_layer_arn" {
  type = string
}

variable "enable_brel_pdf_generator" {
  type        = bool
  default     = false
  description = "Whether the BREL PDF generator module is enabled in this environment"
}