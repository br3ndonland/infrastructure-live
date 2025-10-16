terraform {
  backend "s3" {
    bucket       = var.s3_backend_bucket_name
    key          = "stacks/github/br3ndonland/terraform.tfstate"
    region       = var.s3_backend_bucket_region
    use_lockfile = true
  }
}
