variable "codebuild_image_ecr_url" {
  default = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
  type    = string
}

variable "cross_account_role_arns" {
  type = list(string)
}

variable "github_organisation" {
  default = "communitiesuk"
  type    = string
}

variable "region" {
  default = "eu-west-2"
  type    = string
}

variable "account_ids" {
  type = map(string)
}

variable "tech_docs_bucket_name" {
  default = "epb-ecaas-tech-docs-bucket"
  type    = string
}
