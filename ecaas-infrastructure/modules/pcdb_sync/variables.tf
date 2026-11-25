variable "environment" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "export_filename" {
  type = string
}

variable "pcdb_api_url" {
  type = string
}

variable "pcdb_api_username" {
  type      = string
  sensitive = true
}

variable "pcdb_api_password" {
  type      = string
  sensitive = true
}

variable "log_group_retention_in_days" {
  default = 14
  type    = number
}