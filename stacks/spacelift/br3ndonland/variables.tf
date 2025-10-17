variable "github_branch_default" {
  description = "Default branch of repo containing source code for stacks"
  type        = string
  default     = "main"
}

variable "github_repo" {
  description = "Repo containing source code for stacks"
  type        = string
}

variable "opentofu_version" {
  description = "Version of OpenTofu to use in Spacelift stacks"
  type        = string
}

variable "s3_backend_bucket_key" {
  description = "Path to OpenTofu state in S3 backend bucket"
  type        = string
}

variable "s3_backend_bucket_key_spacelift_oidc" {
  description = "Path to OpenTofu remote state in S3 backend bucket"
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

variable "spacelift_organization" {
  description = "Name of Spacelift organization in which to provision resources"
  type        = string
}
