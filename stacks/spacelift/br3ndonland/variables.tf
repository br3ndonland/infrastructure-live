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

variable "s3_backend_bucket_name" {
  description = "Name of bucket used to store OpenTofu state for S3 backend"
  type        = string
}

variable "s3_backend_bucket_region" {
  description = "Region of bucket used to store OpenTofu state for S3 backend"
  type        = string
}

variable "spacelift_organization" {
  description = "Name of Spacelift organization in which to provision resources"
  type        = string
}
