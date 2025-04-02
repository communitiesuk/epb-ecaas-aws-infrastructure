variable "tracing_config_mode" {
  description = "Can be either PassThrough or Active"
  default     = "Active"
}

variable "log_group_retention_in_days" {
  default = 14
  type    = number
}

variable "front_end_s3_bucket_name" {
  type = string
}

variable "xray_tracing_enabled" {
  type    = bool
  default = false
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "domain_name" {
  type = string
  default = "energy-calculator-integration.digital.communities.gov.uk"
}
