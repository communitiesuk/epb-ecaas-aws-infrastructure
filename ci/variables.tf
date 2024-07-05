variable "region" {
  default = "eu-west-2"
  type    = string
}

variable "github_organisation" {
  default = "communitiesuk"
  type    = string
}

variable "codebuild_image_ecr_url" {
  default = "public.ecr.aws/hashicorp/terraform:latest"
  type    = string
}
