terraform {
  backend "s3" {
    bucket       = var.s3_backend_bucket_name
    key          = "stacks/github/br3ndonland/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}
