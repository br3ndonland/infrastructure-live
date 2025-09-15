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
  description = "GitHub organization settings"
  type = map(object({
    advanced_security             = optional(bool, false)
    billing_email                 = string
    default_repository_permission = optional(string, "none")
  }))
  default = {}
}

variable "repos" {
  description = "Map of configuration attributes for each github_repository resource"
  type = map(map(object({
    name                            = string
    visibility                      = string
    description                     = optional(string)
    gitignore_template              = optional(string)
    is_repo_template                = optional(bool, false)
    from_repo_template              = optional(string)
    topics                          = optional(list(string))
    allow_merge_commit              = optional(bool, false)
    allow_rebase_merge              = optional(bool, false)
    allow_squash_merge              = optional(bool, true)
    enable_github_pages             = optional(bool, false)
    github_pages_cname              = optional(string)
    github_pages_path               = optional(string, "/")
    has_discussions                 = optional(bool, false)
    has_issues                      = optional(bool, false)
    has_vulnerability_alerts        = optional(bool)
    homepage_url                    = optional(string)
    default_branch_name             = optional(string, "main")
    protected_branch_names          = optional(list(string))
    required_approving_review_count = optional(map(number))
    required_deployments            = optional(map(list(string)))
    required_signatures             = optional(map(bool))
    required_status_checks = optional(map(list(object({
      context        = string
      integration_id = optional(number, 0)
    }))))
  })))
}

variable "outside_collaborators" {
  description = "GitHub organization outside collaborators"
  type = map(map(object({
    permission = optional(string, "push")
    repository = string
    username   = string
  })))
  default = {}
}
