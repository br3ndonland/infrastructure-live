locals {
  aws_iam_roles_for_spacelift_oidc = {
    for pair in setproduct(var.spacelift_organizations, var.spacelift_spaces) :
    "${pair[0]}-${pair[1]}" => {
      aws_account_alias      = var.aws_account_alias
      aws_iam_role           = module.spacelift_oidc[pair[0]].aws_iam_roles["spacelift-oidc-${pair[0]}-${pair[1]}"]
      spacelift_organization = pair[0]
      spacelift_space        = pair[1]
    }
  }
}

module "spacelift_oidc" {
  for_each = toset(var.spacelift_organizations)
  source   = "../../../../modules/aws-spacelift-oidc"

  aws_iam_role_claims = {
    for space in var.spacelift_spaces : "spacelift-oidc-${each.value}-${space}" => {
      claims           = ["space:${space}-*"]
      role_description = "Grants access to spaces that manage ${space} resources."
    }
  }
  spacelift_organization = each.value
}

resource "aws_iam_role_policy_attachment" "spacelift_oidc_power_user" {
  for_each   = toset(var.spacelift_organizations)
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  role       = local.aws_iam_roles_for_spacelift_oidc["${each.value}-aws"].aws_iam_role.name
}

data "aws_iam_policy_document" "s3_backend_bucket_access_for_spacelift_space" {
  for_each = toset(var.spacelift_spaces)
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.s3_backend_bucket}"]
    sid       = "S3BucketListActions"
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["stacks/${each.value}", "stacks/${each.value}/*"]
    }
  }
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.s3_backend_bucket}/stacks/${each.value}/*"]
    sid       = "S3ObjectReadActions"
  }
  statement {
    actions   = ["s3:DeleteObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${var.s3_backend_bucket}/stacks/${each.value}/*"]
    sid       = "S3ObjectWriteActions"
  }
}

resource "aws_iam_policy" "s3_backend_bucket_access_for_spacelift_space" {
  for_each    = toset(var.spacelift_spaces)
  name        = "s3-backend-bucket-access-for-${each.value}-stacks"
  description = "Allows the Spacelift OIDC integration for each space to access its state in S3."
  policy      = data.aws_iam_policy_document.s3_backend_bucket_access_for_spacelift_space[each.value].json
}

resource "aws_iam_role_policy_attachment" "s3_backend_bucket_access_for_spacelift_space" {
  for_each   = local.aws_iam_roles_for_spacelift_oidc
  policy_arn = aws_iam_policy.s3_backend_bucket_access_for_spacelift_space[each.value.spacelift_space].arn
  role       = each.value.aws_iam_role.name
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
    resources = ["arn:aws:iam::*:oidc-provider/${each.value}.app.spacelift.io"]
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
    resources = ["arn:aws:iam::*:oidc-provider/${each.value}.app.spacelift.io"]
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
    resources = ["arn:aws:iam::*:role/spacelift-oidc-${each.value}*"]
    sid       = "IAMRolePermissionsManagementActions"
  }
  statement {
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
    ]
    resources = ["arn:aws:iam::*:role/spacelift-oidc-${each.value}*"]
    sid       = "IAMRoleWriteActions"
  }
}

resource "aws_iam_policy" "spacelift_oidc_provisioning" {
  for_each    = toset(var.spacelift_organizations)
  description = "Allows provisioning of resources for Spacelift OIDC (OpenID Connect)."
  name        = "spacelift-oidc-provisioning-${each.value}"
  policy      = data.aws_iam_policy_document.spacelift_oidc_provisioning[each.value].json
}

resource "aws_iam_role_policy_attachment" "spacelift_oidc_provisioning" {
  for_each   = toset(var.spacelift_organizations)
  policy_arn = aws_iam_policy.spacelift_oidc_provisioning[each.value].arn
  role       = module.spacelift_oidc[each.value].aws_iam_roles["spacelift-oidc-${each.value}-aws"].name
}
