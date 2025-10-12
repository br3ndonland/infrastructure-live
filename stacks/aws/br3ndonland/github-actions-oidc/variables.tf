variable "aws_provider_region" {
  description = "AWS region for provider to use"
  type        = string
}

variable "github_repos_with_oidc" {
  description = "Set of GitHub repositories for which to configure GitHub Actions OpenID Connect (OIDC), in owner/repo format"
  type        = set(string)
}
