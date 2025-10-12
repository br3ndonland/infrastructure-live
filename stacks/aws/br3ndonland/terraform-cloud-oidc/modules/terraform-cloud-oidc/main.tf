locals {
  /* Retain case in IAM role names if no separator
  This module supports an input variable that defines the character used to separate
  words in the IAM role name. IAM roles are commonly named in either `PascalCase` or
  `lowercase-with-separators`. This local preserves case if there is no separator
  and if the role name prefix is written in mixed-case (`TerraformCloudOIDCWorkspaceName`),
  or lowercases the name if there is a separator (`terraform-cloud-oidc-workspace-name`). */
  aws_iam_role_name_defaults_projects = {
    for project in var.tfc_projects :
    lower(replace(replace(project, " ", "-"), "/", "-")) => join(
      var.aws_iam_role_separator,
      [
        var.aws_iam_role_prefix,
        var.aws_iam_role_prefix != lower(var.aws_iam_role_prefix) && var.aws_iam_role_separator == ""
        ? replace(project, " ", var.aws_iam_role_separator)
        : lower(replace(project, " ", var.aws_iam_role_separator))
      ]
    )
  }
  aws_iam_role_name_defaults_workspaces = {
    for workspace in var.tfc_workspaces :
    lower(replace(workspace, "/", "-")) => join(
      var.aws_iam_role_separator,
      [
        var.aws_iam_role_prefix,
        var.aws_iam_role_prefix != lower(var.aws_iam_role_prefix) && var.aws_iam_role_separator == ""
        ? replace(workspace, "/", var.aws_iam_role_separator)
        : replace(lower(workspace), "/", var.aws_iam_role_separator)
      ]
    )
  }
  tfc_projects = {
    for project in var.tfc_projects : lower(replace(replace(project, " ", "-"), "/", "-")) => {
      organization = split("/", project)[0]
      project      = split("/", project)[1]
    }
  }
  tfc_workspaces = {
    for workspace in var.tfc_workspaces : lower(replace(workspace, "/", "-")) => {
      organization = split("/", workspace)[0]
      workspace    = split("/", workspace)[1]
    }
  }
  oidc_client_ids    = [var.tfc_aws_audience]
  oidc_issuer_domain = var.tfc_hostname
  oidc_provider = (
    tobool(var.create_oidc_provider) == true
    ? aws_iam_openid_connect_provider.tfc[0]
    : data.aws_iam_openid_connect_provider.tfc[0]
  )
}

# Fetch TLS certificate thumbprint from OIDC provider

data "tls_certificate" "tfc" {
  url = "https://${local.oidc_issuer_domain}"
}

# Create a single OIDC provider

resource "aws_iam_openid_connect_provider" "tfc" {
  count           = tobool(var.create_oidc_provider) == true ? 1 : 0
  client_id_list  = local.oidc_client_ids
  thumbprint_list = [data.tls_certificate.tfc.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.tfc.url
}

data "aws_iam_openid_connect_provider" "tfc" {
  count = tobool(var.create_oidc_provider) == true ? 0 : 1
  url   = data.tls_certificate.tfc.url
}

# Define resource-based role trust policy for each IAM role
# https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_identity-vs-resource.html

data "aws_iam_policy_document" "role_trust_policy_project" {
  for_each = local.tfc_projects
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity", "sts:TagSession"]
    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_domain}:aud"
      values   = local.oidc_provider.client_id_list
    }
    condition {
      test     = "StringLike"
      variable = "${local.oidc_issuer_domain}:sub"
      values = [
        join(":", [
          "organization:${each.value.organization}",
          "project:${each.value.project}",
          "workspace:*",
          "${var.tfc_oidc_custom_claim}",
        ])
      ]
    }
  }
}

data "aws_iam_policy_document" "role_trust_policy_workspace" {
  for_each = local.tfc_workspaces
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity", "sts:TagSession"]
    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_domain}:aud"
      values   = local.oidc_provider.client_id_list
    }
    condition {
      test     = "StringLike"
      variable = "${local.oidc_issuer_domain}:sub"
      values = [
        join(":", [
          "organization:${each.value.organization}",
          "project:*",
          "workspace:${each.value.workspace}",
          "${var.tfc_oidc_custom_claim}",
        ])
      ]
    }
  }
}

# Create IAM roles for each project or workspace and attach a role trust policy to each
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp.html

resource "aws_iam_role" "tfc_project" {
  for_each           = local.tfc_projects
  assume_role_policy = data.aws_iam_policy_document.role_trust_policy_project[each.key].json
  description        = "IAM assumed role for Terraform Cloud in the ${each.value.project} project"
  name = (
    length(lookup(var.aws_iam_role_names, each.value.project, "")) != 0
    ? substr(var.aws_iam_role_names[each.value], 0, 64)
    : substr(local.aws_iam_role_name_defaults_projects[each.key], 0, 64)
  )
}

resource "aws_iam_role" "tfc_workspace" {
  for_each           = local.tfc_workspaces
  assume_role_policy = data.aws_iam_policy_document.role_trust_policy_workspace[each.key].json
  description        = "IAM assumed role for Terraform Cloud in the ${each.value.workspace} workspace"
  name = (
    length(lookup(var.aws_iam_role_names, each.value.workspace, "")) != 0
    ? substr(var.aws_iam_role_names[each.value], 0, 64)
    : substr(local.aws_iam_role_name_defaults_workspaces[each.key], 0, 64)
  )
}
