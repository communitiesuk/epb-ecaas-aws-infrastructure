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
  type    = string
  default = "energy-calculator-integration.digital.communities.gov.uk"
}

variable "ecaas_auth_api_url" {
  type = string
}

variable "ecaas_api_url" {
  type = string
}

variable "cognito_user_pool_id" {
  type = string
}

variable "nuxt_session_password" {
  type      = string
  sensitive = true
}

variable "nuxt_oauth_cognito_redirect_url" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "sentry_auth_token" {
  type      = string
  sensitive = true
}

variable "sentry_dsn" {
  type      = string
  sensitive = true
}

variable "environment_name" {
  type    = string
  default = "integration"
}