variable "environment" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "export_filename" {
  type = string
}

variable "log_group_retention_in_days" {
  default = 14
  type    = number
}