resource "aws_cloudwatch_metric_alarm" "elasticache_throttledCmds" {
  alarm_name                = "elasticache-throttledCmds"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "ThrottledCmds"
  namespace                 = "AWS/ElastiCache"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 0
  alarm_description         = "This metric monitors ElastiCache throttling"
  insufficient_data_actions = []
  alarm_actions = [
    aws_sns_topic.cloudwatch_alerts.arn,
  ]
}