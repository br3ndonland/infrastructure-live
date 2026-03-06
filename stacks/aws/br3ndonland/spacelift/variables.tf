variable "aws_account_alias" {
  description = "Alias (name) of AWS account associated with this stack"
  type        = string
}

variable "aws_provider_region" {
  description = "AWS region for provider to use"
  type        = string
}

variable "s3_backend_bucket_key" {
  description = "Path to OpenTofu state in S3 backend bucket"
  type        = string
}

variable "s3_backend_bucket_name" {
  description = "Name of bucket used to store OpenTofu state for S3 backend"
  type        = string
}

variable "s3_backend_bucket_region" {
  description = "Region of bucket used to store OpenTofu state for S3 backend"
  type        = string
}

variable "s3_backend_bucket_role_arn" {
  description = "ARN of role used to access the OpenTofu S3 backend bucket"
  type        = string
  default     = null
}

variable "s3_backend_bucket_web_identity_token_file" {
  description = <<-DESCRIPTION
    Path to OIDC web identity token file used to access the OpenTofu S3 backend bucket.
    https://search.opentofu.org/provider/hashicorp/aws/latest#assuming-an-iam-role-using-a-web-identity
  DESCRIPTION
  type        = string
  default     = null
}

variable "spacelift_organizations" {
  description = "Set of Spacelift organization names for which to configure OpenID Connect (OIDC)"
  type        = set(string)
}

variable "spacelift_spaces" {
  description = "Set of Spacelift space names for which to configure OpenID Connect (OIDC)"
  type        = set(string)
}
