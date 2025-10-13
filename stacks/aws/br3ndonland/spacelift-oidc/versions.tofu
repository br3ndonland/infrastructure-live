terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4, < 7"
    }
  }
  required_version = ">= 1.10, < 2"
}
