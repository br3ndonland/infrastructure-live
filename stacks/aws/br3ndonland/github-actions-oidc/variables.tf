variable "aws_provider_region" {
  description = "AWS region for provider to use"
  type        = string
}

variable "s3_backend_bucket_name" {
  description = "Name of bucket used to store OpenTofu state for S3 backend"
  type        = string
}

variable "github_repos_with_oidc" {
  description = "Set of GitHub repositories for which to configure GitHub Actions OpenID Connect (OIDC), in owner/repo format"
  type        = set(string)
}
