variable "aws_account_alias" {
  description = "Alias (name) of AWS account associated with this stack"
  type        = string
}

variable "aws_provider_region" {
  description = "AWS region for provider to use"
  type        = string
}

variable "s3_backend_bucket_name" {
  description = "Name of bucket used to store OpenTofu state for S3 backend"
  type        = string
}

variable "spacelift_organizations" {
  description = "Set of Spacelift organization names for which to configure OpenID Connect (OIDC)"
  type        = set(string)
}

variable "spacelift_spaces" {
  description = "Set of Spacelift space names for which to configure OpenID Connect (OIDC)"
  type        = set(string)
}
