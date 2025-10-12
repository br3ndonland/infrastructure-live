terraform {
  backend "s3" {
    bucket       = "br3ndonland-infrastructure-live"
    key          = "stacks/spacelift/br3ndonland/spacelift-admin/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}
