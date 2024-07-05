output "ci_role_arn" {
  value       = aws_iam_role.ci_role.arn
  description = "The arn of the ci-server role"
}
