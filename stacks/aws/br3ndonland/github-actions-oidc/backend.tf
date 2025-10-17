terraform {
  backend "s3" {
    bucket       = var.s3_backend_bucket_name
    key          = var.s3_backend_bucket_key
    region       = var.s3_backend_bucket_region
    use_lockfile = true
    assume_role_with_web_identity = var.s3_backend_bucket_role_arn != null ? {
      role_arn                = var.s3_backend_bucket_role_arn
      web_identity_token_file = var.s3_backend_bucket_web_identity_token_file
    } : null
  }
}
