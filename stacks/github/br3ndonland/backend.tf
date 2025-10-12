terraform {
  backend "s3" {
    bucket       = "br3ndonland-infrastructure-live"
    key          = "stacks/github/br3ndonland/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}
