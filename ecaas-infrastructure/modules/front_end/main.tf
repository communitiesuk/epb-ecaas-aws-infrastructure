terraform {
  required_version = "~> 1.11"

  required_providers {
    aws = {
      version = "~>5.0"
      source  = "hashicorp/aws"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

provider "aws" {
  alias  = "us-east"
  region = "us-east-1"
}
