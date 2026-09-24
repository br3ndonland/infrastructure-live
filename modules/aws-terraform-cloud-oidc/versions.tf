terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.66"
    }
  }
  required_version = "~> 1.0"
}
