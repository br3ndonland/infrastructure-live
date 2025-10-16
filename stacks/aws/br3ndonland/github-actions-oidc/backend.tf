terraform {
  backend "s3" {
    bucket       = var.s3_backend_bucket_name
    key          = "stacks/aws/br3ndonland/github-actions-oidc/terraform.tfstate"
    region       = var.s3_backend_bucket_region
    use_lockfile = true
  }
}
