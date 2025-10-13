locals {
  /* Retain case in IAM role names if no separator

  This module supports an input variable that defines the character used to separate words in the IAM role name.
  IAM roles are commonly named in either `PascalCase` or `kebab-case`. This local preserves case if there is no
  separator and if the role name prefix is written in mixed-case (`SpaceliftOIDCOrganizationName`),
  or lowercases the name if there is a separator (`spacelift-oidc-organization-name`).
  */
  aws_iam_role_name_default = join(
    var.aws_iam_role_separator,
    [
      var.aws_iam_role_prefix,
      var.aws_iam_role_prefix != lower(var.aws_iam_role_prefix) && var.aws_iam_role_separator == ""
      ? var.spacelift_organization
      : lower(var.spacelift_organization)
    ]
  )
  aws_iam_role_claim_default = {
    "${local.aws_iam_role_name_default}" = {
      claims           = []
      role_description = "IAM assumed role for the ${var.spacelift_organization} Spacelift organization."
    }
  }
  aws_iam_roles      = var.aws_iam_role_claims != null ? var.aws_iam_role_claims : local.aws_iam_role_claim_default
  oidc_client_ids    = [local.oidc_issuer_domain]
  oidc_issuer_domain = "${var.spacelift_organization}.${var.spacelift_mothership_domain}"
}

# Fetch TLS certificate thumbprint from OIDC provider

data "tls_certificate" "spacelift" {
  url = "https://${local.oidc_issuer_domain}/.well-known/openid-configuration"
}

# Create a single OIDC provider

resource "aws_iam_openid_connect_provider" "spacelift" {
  client_id_list  = local.oidc_client_ids
  thumbprint_list = [data.tls_certificate.spacelift.certificates[0].sha1_fingerprint]
  url             = "https://${local.oidc_issuer_domain}"
}

# Define resource-based role trust policy for each IAM role
# https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_identity-vs-resource.html

data "aws_iam_policy_document" "role_trust_policy" {
  for_each = local.aws_iam_roles
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity", "sts:TagSession"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.spacelift.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_domain}:aud"
      values   = local.oidc_client_ids
    }
    dynamic "condition" {
      for_each = length(each.value.claims) > 0 ? [""] : []
      content {
        test     = "StringLike"
        variable = "${local.oidc_issuer_domain}:sub"
        values   = each.value.claims
      }
    }
  }
}

# Create IAM roles and attach a role trust policy to each role
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp.html

resource "aws_iam_role" "spacelift_oidc" {
  for_each           = local.aws_iam_roles
  assume_role_policy = data.aws_iam_policy_document.role_trust_policy[each.key].json
  description        = each.value.role_description
  name               = substr(each.key, 0, 64)
}
