variable "environment" {
  type = string
}

variable "tracing_config_mode" {
  type        = string
  description = "Can be either PassThrough or Active"
  default     = "Active"
}

variable "log_group_retention_in_days" {
  default = 14
  type    = number
}

variable "lambda_memory_size" {
  default = 1769 # gives 1 vCPU
  type    = number
}

variable "lambda_function_name" {
  type = string
}

variable "products_table_arn" {
  type = string
}