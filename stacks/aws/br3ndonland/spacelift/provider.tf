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

provider "aws" {
  # ECR Public resources only support us-east-1.
  # https://search.opentofu.org/provider/hashicorp/aws/latest/docs/resources/ecrpublic_repository
  # https://github.com/hashicorp/terraform-provider-aws/issues/18047
  alias  = "us_east_1"
  region = "us-east-1"
  dynamic "assume_role_with_web_identity" {
    for_each = var.s3_backend_bucket_role_arn != null ? [""] : []
    content {
      role_arn                = var.s3_backend_bucket_role_arn
      web_identity_token_file = var.s3_backend_bucket_web_identity_token_file
    }
  }
}
