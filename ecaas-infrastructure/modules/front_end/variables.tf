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
