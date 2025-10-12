terraform {
  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = ">= 1, < 2"
    }
  }
  required_version = ">= 1.10, < 2"
}
