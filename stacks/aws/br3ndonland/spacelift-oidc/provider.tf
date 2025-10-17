provider "aws" {
  region = var.aws_provider_region
  dynamic "assume_role_with_web_identity" {
    for_each = var.s3_backend_bucket_role_arn != null ? [""] : []
    content {
      role_arn                = var.s3_backend_bucket_role_arn
      web_identity_token_file = var.s3_backend_bucket_web_identity_token_file
    }
  }
}
