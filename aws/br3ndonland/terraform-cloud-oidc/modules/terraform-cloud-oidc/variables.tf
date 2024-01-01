variable "aws_iam_role_names" {
  description = <<-DESCRIPTION
    Optional mapping of Terraform Cloud projects or workspaces to names of IAM roles that will be assumed for OIDC.
    If set, the IAM role name will be exactly the variable value (64 characters max).

    Example:

    `{ "long-terraform-cloud-organization-name/Long Terraform Cloud Project Name" = "custom-role-name" }`

    If unset, the default name for each IAM role will be
    `<aws_iam_role_prefix><aws_iam_role_separator><organization_name><aws_iam_role_separator><project_or_workspace_name>`,
    truncated to 64 characters.
  DESCRIPTION
  type        = map(string)
  default     = {}
  validation {
    condition     = alltrue([for key, value in var.aws_iam_role_names : length(value) <= 64])
    error_message = "The IAM role name must be less than or equal to 64 characters."
  }
}

variable "aws_iam_role_prefix" {
  description = "Prefix for name of IAM role that will be assumed by Terraform Cloud for OIDC"
  type        = string
  default     = "terraform-cloud-oidc"
}

variable "aws_iam_role_separator" {
  description = "Character to use to separate words in name of IAM role"
  type        = string
  default     = "-"
}

variable "create_oidc_provider" {
  description = <<-DESCRIPTION
    Each AWS account can only have one OIDC provider for a given URL. Attempts to create a second
    provider will error with `409 EntityAlreadyExists`. This module accommodates this limitation
    by allowing multiple projects and workspaces to be passed in. A single module block will create
    a single OIDC provider and a role for each project or workspace. In some cases, such as during
    testing, it may be useful to avoid creating the OIDC provider entirely. Set this variable to
    `false` to disable creation of the OIDC provider.
  DESCRIPTION
  type        = bool
  default     = true
}

variable "tfc_aws_audience" {
  description = "The audience value to use in run identity tokens"
  type        = string
  default     = "aws.workload.identity"
}

variable "tfc_hostname" {
  description = "Terraform Cloud (TFC) or Terraform Enterprise (TFE) hostname"
  type        = string
  default     = "app.terraform.io"
}

variable "tfc_oidc_custom_claim" {
  description = <<-DESCRIPTION
    Custom OIDC claim for more specific access scope. See the
    [docs](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/workload-identity-tokens)
    for supported custom claims.
  DESCRIPTION
  type        = string
  default     = "run_phase:*"
}

variable "tfc_projects" {
  description = "Set of Terraform Cloud project names for which to configure OIDC, in organization/project format"
  type        = set(string)
  default     = []
}

variable "tfc_workspaces" {
  description = "Set of Terraform Cloud workspace names for which to configure OIDC, in organization/workspace format"
  type        = set(string)
  default     = []
}
