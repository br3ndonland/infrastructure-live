locals {
  spacelift_organization_spaces = merge([
    for organization, spaces in var.spacelift_spaces : {
      for space in spaces : "${organization}-${space}" => {
        aws_account_alias      = var.aws_account_alias
        spacelift_organization = organization
        spacelift_space        = space
      }
    }
  ]...)

  aws_iam_roles_for_spacelift = {
    for key, value in local.spacelift_organization_spaces : key => {
      aws_account_alias = value.aws_account_alias
      aws_iam_role_external_id = {
        arn  = aws_iam_role.external_id[key].arn
        name = aws_iam_role.external_id[key].name
      }
      aws_iam_role_oidc      = module.spacelift_oidc[value.spacelift_organization].aws_iam_roles["spacelift-oidc-${key}"]
      spacelift_organization = value.spacelift_organization
      spacelift_space        = value.spacelift_space
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "external_id_assume_role_policy" {
  for_each = local.spacelift_organization_spaces
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["324880187172"]
    }

    condition {
      test     = "StringLike"
      variable = "sts:ExternalId"
      values   = ["${each.value.spacelift_organization}@*@${each.value.spacelift_space}-${each.value.aws_account_alias}*@*"]
    }
  }
}

resource "aws_iam_role" "external_id" {
  for_each           = local.spacelift_organization_spaces
  assume_role_policy = data.aws_iam_policy_document.external_id_assume_role_policy[each.key].json
  description        = "Grants access to spaces that manage ${each.value.spacelift_space} resources."
  name               = "spacelift-external-id-${each.key}"
}

module "spacelift_oidc" {
  for_each = var.spacelift_organizations
  source   = "../../../../modules/aws-spacelift-oidc"

  aws_iam_role_claims = {
    for space in var.spacelift_spaces[each.key] :
    "spacelift-oidc-${each.key}-${space}" => {
      claims           = ["space:${space}-*"]
      role_description = "Grants access to spaces that manage ${space} resources."
    }
  }
  spacelift_organization = each.key
}

resource "aws_iam_role_policy_attachment" "spacelift_external_id_power_user" {
  for_each = {
    for key, value in local.aws_iam_roles_for_spacelift :
    key => value if endswith(key, "-aws")
  }
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  role       = each.value.aws_iam_role_external_id.name
}

resource "aws_iam_role_policy_attachment" "spacelift_oidc_power_user" {
  for_each = {
    for key, value in local.aws_iam_roles_for_spacelift :
    key => value if endswith(key, "-aws")
  }
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  role       = each.value.aws_iam_role_oidc.name
}

data "aws_iam_policy_document" "s3_backend_bucket_access_for_spacelift_space" {
  for_each = local.aws_iam_roles_for_spacelift
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.s3_backend_bucket_name}"]
    sid       = "S3BucketListActions"
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["stacks/${each.value.spacelift_space}", "stacks/${each.value.spacelift_space}/*"]
    }
  }
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.s3_backend_bucket_name}/stacks/${each.value.spacelift_space}/*"]
    sid       = "S3ObjectReadActions"
  }
  statement {
    actions   = ["s3:DeleteObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${var.s3_backend_bucket_name}/stacks/${each.value.spacelift_space}/*"]
    sid       = "S3ObjectWriteActions"
  }
}

resource "aws_iam_policy" "s3_backend_bucket_access_for_spacelift_space" {
  for_each    = local.aws_iam_roles_for_spacelift
  name        = "s3-backend-bucket-access-for-${each.value.spacelift_space}-stacks"
  description = "Allows the Spacelift OIDC integration for each space to access its state in S3."
  policy      = data.aws_iam_policy_document.s3_backend_bucket_access_for_spacelift_space[each.key].json
}

resource "aws_iam_role_policy_attachment" "s3_backend_bucket_access_for_spacelift_space_for_external_id_role" {
  for_each   = local.aws_iam_roles_for_spacelift
  policy_arn = aws_iam_policy.s3_backend_bucket_access_for_spacelift_space[each.key].arn
  role       = each.value.aws_iam_role_external_id.name
}

resource "aws_iam_role_policy_attachment" "s3_backend_bucket_access_for_spacelift_space_for_oidc_role" {
  for_each   = local.aws_iam_roles_for_spacelift
  policy_arn = aws_iam_policy.s3_backend_bucket_access_for_spacelift_space[each.key].arn
  role       = each.value.aws_iam_role_oidc.name
}

data "aws_iam_policy_document" "s3_backend_bucket_access_for_aws_remote_state" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.s3_backend_bucket_name}"]
    sid       = "S3BucketListActions"
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["stacks/aws", "stacks/aws/*"]
    }
  }
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.s3_backend_bucket_name}/stacks/aws/*"]
    sid       = "S3ObjectReadActions"
  }
}

resource "aws_iam_policy" "s3_backend_bucket_access_for_aws_remote_state" {
  name = "s3-backend-bucket-access-for-aws-remote-state"
  description = join(" ", [
    "Allows AWS IAM roles used for other stacks to access remote state from AWS stacks.",
    "This access is needed for backend and provider configurations,",
    "as well as for provisioning spacelift_aws_integration resources."
  ])
  policy = data.aws_iam_policy_document.s3_backend_bucket_access_for_aws_remote_state.json
}

resource "aws_iam_role_policy_attachment" "s3_backend_bucket_access_for_aws_remote_state_for_external_id_role" {
  for_each = {
    for key, value in local.aws_iam_roles_for_spacelift :
    key => value if !endswith(key, "-aws")
  }
  policy_arn = aws_iam_policy.s3_backend_bucket_access_for_aws_remote_state.arn
  role       = each.value.aws_iam_role_external_id.name
}

resource "aws_iam_role_policy_attachment" "s3_backend_bucket_access_for_aws_remote_state_for_oidc_role" {
  for_each = {
    for key, value in local.aws_iam_roles_for_spacelift :
    key => value if !endswith(key, "-aws")
  }
  policy_arn = aws_iam_policy.s3_backend_bucket_access_for_aws_remote_state.arn
  role       = each.value.aws_iam_role_oidc.name
}

data "aws_iam_policy_document" "spacelift_oidc_provisioning" {
  for_each = toset(var.spacelift_organizations)
  statement {
    actions = [
      "iam:ListOpenIDConnectProviders",
      "iam:ListOpenIDConnectProviderTags",
    ]
    resources = ["*"]
    sid       = "IAMOIDCProviderListActions"
  }
  statement {
    actions   = ["iam:GetOpenIDConnectProvider"]
    resources = ["*"]
    sid       = "IAMOIDCProviderReadActions"
  }
  statement {
    actions = [
      "iam:TagOpenIDConnectProvider",
      "iam:UntagOpenIDConnectProvider",
    ]
    resources = ["arn:aws:iam::*:oidc-provider/${each.key}.app.spacelift.io"]
    sid       = "IAMOIDCProviderTaggingActions"
  }
  statement {
    actions = [
      "iam:AddClientIDToOpenIDConnectProvider",
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:RemoveClientIDFromOpenIDConnectProvider",
      "iam:UpdateOpenIDConnectProviderThumbprint",
    ]
    resources = ["arn:aws:iam::*:oidc-provider/${each.key}.app.spacelift.io"]
    sid       = "IAMOIDCProviderWriteActions"
  }
  statement {
    actions = [
      "iam:ListEntitiesForPolicy",
      "iam:ListPolicies",
      "iam:ListPolicyVersions",
      "iam:ListUserPolicies",
    ]
    resources = ["*"]
    sid       = "IAMPolicyListActions"
  }
  statement {
    actions = [
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
    ]
    resources = ["*"]
    sid       = "IAMPolicyReadActions"
  }
  statement {
    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
    ]
    resources = ["arn:aws:iam::*:policy/spacelift*"]
    sid       = "IAMPolicyPermissionsManagementActions"
  }
  statement {
    actions = [
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:ListRoles",
    ]
    resources = ["*"]
    sid       = "IAMRoleListActions"
  }
  statement {
    actions   = ["iam:GetRole"]
    resources = ["*"]
    sid       = "IAMRoleReadActions"
  }
  statement {
    actions = [
      "iam:AttachRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:UpdateAssumeRolePolicy",
    ]
    resources = ["arn:aws:iam::*:role/spacelift-oidc-${each.key}*"]
    sid       = "IAMRolePermissionsManagementActions"
  }
  statement {
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
    ]
    resources = ["arn:aws:iam::*:role/spacelift-oidc-${each.key}*"]
    sid       = "IAMRoleWriteActions"
  }
}

resource "aws_iam_policy" "spacelift_oidc_provisioning" {
  for_each    = toset(var.spacelift_organizations)
  description = "Allows provisioning of resources for Spacelift OIDC (OpenID Connect)."
  name        = "spacelift-oidc-provisioning-${each.key}"
  policy      = data.aws_iam_policy_document.spacelift_oidc_provisioning[each.value].json
}

resource "aws_iam_role_policy_attachment" "spacelift_oidc_provisioning_for_external_id_role" {
  for_each = {
    for key, value in local.aws_iam_roles_for_spacelift :
    key => value if endswith(key, "-aws")
  }
  policy_arn = aws_iam_policy.spacelift_oidc_provisioning[each.value.spacelift_organization].arn
  role       = each.value.aws_iam_role_external_id.name
}

resource "aws_iam_role_policy_attachment" "spacelift_oidc_provisioning_for_oidc_role" {
  for_each = {
    for key, value in local.aws_iam_roles_for_spacelift :
    key => value if endswith(key, "-aws")
  }
  policy_arn = aws_iam_policy.spacelift_oidc_provisioning[each.value.spacelift_organization].arn
  role       = each.value.aws_iam_role_oidc.name
}

data "aws_iam_policy_document" "github_actions_oidc_provisioning" {
  statement {
    actions = [
      "iam:ListOpenIDConnectProviders",
      "iam:ListOpenIDConnectProviderTags",
    ]
    resources = ["*"]
    sid       = "IAMOIDCProviderListActions"
  }
  statement {
    actions   = ["iam:GetOpenIDConnectProvider"]
    resources = ["*"]
    sid       = "IAMOIDCProviderReadActions"
  }
  statement {
    actions = [
      "iam:TagOpenIDConnectProvider",
      "iam:UntagOpenIDConnectProvider",
    ]
    resources = ["arn:aws:iam::*:oidc-provider/token.actions.githubusercontent.com"]
    sid       = "IAMOIDCProviderTaggingActions"
  }
  statement {
    actions = [
      "iam:AddClientIDToOpenIDConnectProvider",
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:RemoveClientIDFromOpenIDConnectProvider",
      "iam:UpdateOpenIDConnectProviderThumbprint",
    ]
    resources = ["arn:aws:iam::*:oidc-provider/token.actions.githubusercontent.com"]
    sid       = "IAMOIDCProviderWriteActions"
  }
  statement {
    actions = [
      "iam:ListEntitiesForPolicy",
      "iam:ListPolicies",
      "iam:ListPolicyVersions",
      "iam:ListUserPolicies",
    ]
    resources = ["*"]
    sid       = "IAMPolicyListActions"
  }
  statement {
    actions = [
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
    ]
    resources = ["*"]
    sid       = "IAMPolicyReadActions"
  }
  statement {
    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
    ]
    resources = ["arn:aws:iam::*:policy/github*"]
    sid       = "IAMPolicyPermissionsManagementActions"
  }
  statement {
    actions = [
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:ListRoles",
    ]
    resources = ["*"]
    sid       = "IAMRoleListActions"
  }
  statement {
    actions   = ["iam:GetRole"]
    resources = ["*"]
    sid       = "IAMRoleReadActions"
  }
  statement {
    actions = [
      "iam:AttachRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:UpdateAssumeRolePolicy",
    ]
    resources = ["arn:aws:iam::*:role/github*"]
    sid       = "IAMRolePermissionsManagementActions"
  }
  statement {
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
    ]
    resources = ["arn:aws:iam::*:role/github*"]
    sid       = "IAMRoleWriteActions"
  }
}

resource "aws_iam_policy" "github_actions_oidc_provisioning" {
  description = "Allows provisioning of resources for GitHub Actions OIDC (OpenID Connect)."
  name        = "github-actions-oidc-provisioning"
  policy      = data.aws_iam_policy_document.github_actions_oidc_provisioning.json
}

resource "aws_iam_role_policy_attachment" "github_actions_oidc_provisioning_for_external_id_role" {
  for_each = {
    for key, value in local.aws_iam_roles_for_spacelift :
    key => value if endswith(key, "-aws")
  }
  policy_arn = aws_iam_policy.github_actions_oidc_provisioning.arn
  role       = each.value.aws_iam_role_external_id.name
}

resource "aws_iam_role_policy_attachment" "github_actions_oidc_provisioning_for_oidc_role" {
  for_each = {
    for key, value in local.aws_iam_roles_for_spacelift :
    key => value if endswith(key, "-aws")
  }
  policy_arn = aws_iam_policy.github_actions_oidc_provisioning.arn
  role       = each.value.aws_iam_role_oidc.name
}
