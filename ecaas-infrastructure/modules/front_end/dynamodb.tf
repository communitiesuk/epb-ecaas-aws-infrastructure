resource "aws_dynamodb_table" "user_sessions_table" {
  name           = "sessions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "session_id"

  attribute {
    name = "session_id"
    type = "S"
  }
  ttl {
    enabled        = true
    attribute_name = "ttl"
  }
  # point_in_time_recovery {
  #   enabled = true
  # }
}


