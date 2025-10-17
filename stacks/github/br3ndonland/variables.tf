variable "op_service_account_token" {
  description = "1Password Service Account token"
  type        = string
  default     = null
}

variable "op_vault" {
  description = "1Password vault UUID or name"
  type        = string
}

variable "op_vault_item_github_token" {
  description = "1Password item containing GitHub Personal Access Token (PAT) for org admin"
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

variable "owner" {
  description = "GitHub owner (user or organization) for the workspace"
  type        = string
}

variable "token" {
  description = "GitHub Personal Access Token (PAT) for org admin"
  sensitive   = true
  type        = string
  default     = null
}

variable "organization_settings" {
  description = "GitHub organization settings. Each key should be the name of a GitHub organization."
  type = map(object({
    advanced_security             = optional(bool, false)
    billing_email                 = string
    default_repository_permission = optional(string, "none")
  }))
  default = {}
}

variable "repos" {
  description = <<-DESCRIPTION
    Map of configuration attributes for each `github_repository` resource.

    Each top-level map key should be the name of a GitHub user or organization.
    Within each user or org map, each key should be the name of a repo.

    Values for each repo should correspond to the given object type attributes.

    - For `required_deployments`, each map key should be the name of a ruleset ("branches" or "tags").
      Within each of those maps, each list item should be the name of a deployment environment.
    - For `required_status_checks`, each map key should be the name of a ruleset ("branches" or "tags").
      Within each of those maps, each key should be the name of a check and each value should be an integration ID.
      Use `15368` as the integration ID for GitHub Actions, or `0` to allow any integration ID.
  DESCRIPTION
  type = map(map(object({
    # general settings
    visibility               = string
    description              = optional(string)
    homepage_url             = optional(string)
    topics                   = optional(list(string))
    from_repo_template       = optional(string)
    gitignore_template       = optional(string)
    has_discussions          = optional(bool, false)
    has_issues               = optional(bool, false)
    has_vulnerability_alerts = optional(bool)
    is_repo_template         = optional(bool, false)

    # default branch
    default_branch_name = optional(string, "main")

    # pull requests
    allow_merge_commit = optional(bool, false)
    allow_rebase_merge = optional(bool, false)
    allow_squash_merge = optional(bool, true)

    # pages
    enable_github_pages = optional(bool, false)
    github_pages_cname  = optional(string)
    github_pages_path   = optional(string, "/")

    # rules
    protected_branch_names          = optional(list(string))
    required_approving_review_count = optional(number, 1)
    required_deployments            = optional(map(list(string)))
    required_signatures             = optional(map(bool))
    required_status_checks          = optional(map(map(number)))
  })))
}

variable "outside_collaborators" {
  description = <<-DESCRIPTION
    GitHub organization outside collaborators.

    Each top-level map key should be the name of a GitHub user or organization.
    Within each user or org map, each key should be a combination of collaborator name and repo name.

    Values for each repo should correspond to the given object type attributes.
  DESCRIPTION
  type = map(map(object({
    permission = optional(string, "push")
    repository = string
    username   = string
  })))
  default = {}
}
