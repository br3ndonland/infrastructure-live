terraform {
  backend "s3" {
    bucket       = var.s3_backend_bucket_name
    key          = "stacks/spacelift/br3ndonland/terraform.tfstate"
    region       = var.s3_backend_bucket_region
    use_lockfile = true
  }
}

data "terraform_remote_state" "spacelift_oidc" {
  # This data source allows the AWS IAM role used for the Spacelift space to access state from AWS stacks.
  # This access is needed for provisioning `spacelift_aws_integration` resources.
  backend = "s3"
  config = {
    bucket = var.s3_backend_bucket_name
    key    = "stacks/aws/br3ndonland/spacelift-oidc/terraform.tfstate"
    region = var.s3_backend_bucket_region
  }
}
