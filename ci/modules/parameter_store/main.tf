terraform {
  required_version = "~> 1.11"

  required_providers {
    aws = {
      version = "~>5.63"
      source  = "hashicorp/aws"
    }
  }
}
