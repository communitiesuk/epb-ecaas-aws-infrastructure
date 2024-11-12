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
