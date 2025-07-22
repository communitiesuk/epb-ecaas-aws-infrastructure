variable "region" {
  default = "eu-west-2"
  type    = string
}

variable "ci_account_id" {
  type = string
}

variable "api_domain_name" {
  type = string
}

variable "frontend_domain_name" {
  type = string
}

variable "nuxt_session_password" {
  type      = string
  sensitive = true
}

variable "parameters" {
  description = "A map of parameter values. Keys should be a subset of the ones passed to 'parameters' module."
  type        = map(string)
  sensitive   = true
}
variable "environment" {
  type = string
}

variable "sentry_auth_token" {
  type      = string
  sensitive = true
}

variable "sentry_dsn" {
  type      = string
  sensitive = true
}
