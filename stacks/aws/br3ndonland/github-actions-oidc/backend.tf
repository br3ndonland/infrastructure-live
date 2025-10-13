terraform {
  backend "s3" {
    bucket       = var.s3_backend_bucket
    key          = "stacks/aws/br3ndonland/github-actions-oidc/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}
