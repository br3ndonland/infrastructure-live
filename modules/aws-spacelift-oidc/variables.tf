variable "aws_iam_role_claims" {
  description = <<-DESCRIPTION
    Optional mapping of IAM role names to custom OIDC subject claims.

    By default, this module will provision a single AWS IAM role for all stacks in the Spacelift organization.
    As seen in the [Spacelift docs](https://docs.spacelift.io/integrations/cloud-providers/oidc/aws-oidc),
    role trust policies can be customized with more specific OIDC subject claims to only allow the role to be
    assumed by certain spaces or stacks. There is only limited support for custom OIDC subject claims as seen in the
    [docs](https://feedback.spacelift.io/p/allow-adding-space-hierarchy-in-oidc-subject). Note that `space:` claims
    must reference the space _id_, not the space name.
  DESCRIPTION
  type = map(object({
    claims           = list(string)
    role_description = optional(string, "")
  }))
  default = null
}

variable "aws_iam_role_prefix" {
  description = "Prefix for name of IAM role that will be assumed by GitHub for OIDC"
  type        = string
  default     = "spacelift-oidc"
}

variable "aws_iam_role_separator" {
  description = "Character to use to separate words in name of IAM role"
  type        = string
  default     = "-"
}

variable "spacelift_mothership_domain" {
  description = "Spacelift Mothership domain"
  type        = string
  default     = "app.spacelift.io"
}

variable "spacelift_organization" {
  description = "Name of Spacelift organization for which to configure OIDC"
  type        = string
}
