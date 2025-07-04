variable "region" {
  type = string
}

variable "slack_webhook_url" {
  type = string
}

variable "main_slack_webhook_url" {
  type = string
}

variable "main_slack_alerts" {
  type = number
}

variable "cloudtrail_log_group_name" {
  type = string
}