variable "api_version" {
  default = "0.0.2"
  type    = string
}

variable "region" {
  type = string
}

variable "tracing_config_mode" {
  description = "Can be either PassThrough or Active"
  default     = "Active"
}

variable "cdn_certificate_arn" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "xray_tracing_enabled" {
  description = "Enables the XRay tracing and will create the necessary IAM permissions"
  type        = bool
  default     = true
}

variable "stage_name" {
  default = "Deployment"
  type    = string
}

variable "log_group_retention_in_days" {
  default = 14
  type    = number
}
