terraform {
  cloud {
    organization = "br3ndonland"
    workspaces {
      name = "terraform-cloud-oidc-br3ndonland"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0, < 6.0"
    }
  }
  required_version = ">= 1.8, < 2"
}
