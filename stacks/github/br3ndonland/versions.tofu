terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6, < 7"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = ">= 2, < 3"
    }
  }
  required_version = ">= 1.10, < 2"
}
