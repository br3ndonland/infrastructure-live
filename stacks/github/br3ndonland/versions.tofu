terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6, < 7"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = ">= 3, < 4"
    }
  }
  required_version = ">= 1.10, < 2"
}
