variable "region" {
  type = string
}

variable "slack_webhook_url" {
  type      = string
  sensitive = true
}

variable "main_slack_webhook_url" {
  type      = string
  sensitive = true
}

variable "main_slack_alerts" {
  type = number
}
