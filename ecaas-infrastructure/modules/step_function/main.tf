resource "aws_sfn_state_machine" "parallel_processor" {
    name = "parallel-lambda-processor"
    role_arn = aws_iam_role.sfn_role.arn
    type = "EXPRESS"

    logging_configuration {
      log_destination = "${aws_cloudwatch_log_group.sfn_logs.arn}:*"
      include_execution_data = true
      level = "ERROR"
    }

    definition = jsonencode({
        Comment = "Synchronous Express workflow for parallel (HEM) calculation; fails fast on error"
        StartAt = "ProcessItemsInParallel"
        States = {
            ProcessItemsInParallel = {
                Type = "Map"
                ItemsPath = "$.items"
                MaxConcurrency = 4
                ItemProcessor = {
                    ProcessorConfig = {
                        Mode = "INLINE"
                    }
                    StartAt = "InvokeWorkerLambda"
                    States = {
                        InvokeWorkerLambda = {
                            Type = "Task"
                            Resource = "arn:aws:states:::lambda:invoke"
                            OutputPath = "$.Payload"
                            Parameters = {
                                FunctionName = var.worker_lambda_arn
                                "Payload.$" = "$"
                            }
                            // only retry transient throttling, not worker errors
                            Retry = [
                                {
                                    ErrorEquals = ["Lambda.TooManyRequestsException"]
                                    IntervalSeconds = 1
                                    MaxAttempts = 1
                                    BackoffRate = 1
                                }
                            ]
                            End = true
                        }
                    }
                }
                End = true
            }
        }
    })
}


