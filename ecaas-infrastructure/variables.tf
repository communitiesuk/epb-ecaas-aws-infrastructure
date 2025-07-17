variable "region" {
  default = "eu-west-2"
  type    = string
}

variable "ci_account_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "subject_alternative_names" {
  type = list(string)
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
