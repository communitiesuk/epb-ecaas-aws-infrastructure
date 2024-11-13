terraform {
  required_version = "~>1.3"

  required_providers {
    aws = {
      version = "~>5.0"
      source  = "hashicorp/aws"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.2"
    }
  }
}

