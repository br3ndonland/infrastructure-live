terraform {
  cloud {
    organization = "br3ndonland"
    workspaces {
      name = "github-br3ndonland"
    }
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 5, < 6"
    }
  }
  required_version = ">= 1.8, < 2"
}
