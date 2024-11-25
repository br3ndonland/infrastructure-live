terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 5, < 6"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = ">= 2, < 3"
    }
  }
  required_version = ">= 1.8, < 2"
}
