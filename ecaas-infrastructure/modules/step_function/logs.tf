resource "aws_cloudwatch_log_group" "sfn_logs" {
  name              = "/aws/vendedlogs/states/parallel-lambda-processor"
  retention_in_days = 14
}
