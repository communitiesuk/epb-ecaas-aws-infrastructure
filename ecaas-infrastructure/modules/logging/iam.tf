data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "cloudwatch_access" {
  name = "cloudwatch-write-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*"
      }
    ]
  })
}

data "aws_iam_policy_document" "trusted_events_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/events/*:*"]

    principals {
      identifiers = ["events.amazonaws.com", "delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "trusted_events_policy" {
  policy_document = data.aws_iam_policy_document.trusted_events_policy_document.json
  policy_name     = "TrustEventsToStoreLogEvents"
}
