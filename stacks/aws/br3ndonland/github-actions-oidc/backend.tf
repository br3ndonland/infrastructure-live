terraform {
  backend "s3" {
    bucket       = "br3ndonland-infrastructure-live"
    key          = "stacks/aws/br3ndonland/github-actions-oidc/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}
