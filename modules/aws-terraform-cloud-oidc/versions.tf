terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.64"
    }
  }
  required_version = "~> 1.0"
}
