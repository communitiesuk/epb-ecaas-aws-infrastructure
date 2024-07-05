variable "codebuild_image_ecr_url" {
  default = "public.ecr.aws/hashicorp/terraform:latest"
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
