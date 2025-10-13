terraform {
  backend "s3" {
    bucket       = var.s3_backend_bucket
    key          = "stacks/spacelift/br3ndonland/spacelift-admin/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}
