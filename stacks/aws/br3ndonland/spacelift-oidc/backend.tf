terraform {
  backend "s3" {
    bucket       = var.s3_backend_bucket_name
    key          = "stacks/aws/br3ndonland/spacelift-oidc/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}
