terraform {
  backend "s3" {
    bucket       = var.s3_backend_bucket_name
    key          = var.s3_backend_bucket_key
    region       = var.s3_backend_bucket_region
    use_lockfile = true
  }
}
