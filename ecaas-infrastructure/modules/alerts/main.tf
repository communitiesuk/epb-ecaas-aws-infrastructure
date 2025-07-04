terraform {
  required_version = "~>1.3"

  required_providers {
    aws = {
      version = "~>5.0"
      source  = "hashicorp/aws"
    }
    archive = {
      version = "~>2.0"
      source  = "hashicorp/archive"
    }
  }
}
