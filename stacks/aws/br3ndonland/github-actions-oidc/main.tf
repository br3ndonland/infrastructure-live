locals {
  github_repos = {
    for repo in var.github_repos_with_oidc :
    replace(repo, "/", "-") => {
      owner = split("/", repo)[0]
      repo  = split("/", repo)[1]
    }
  }
}

module "github_actions_oidc" {
  source       = "github.com/br3ndonland/terraform-aws-github-actions-oidc?ref=0.7.0"
  github_repos = var.github_repos_with_oidc
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

resource "aws_iam_role_policy_attachment" "github_actions_oidc_provisioning" {
  role       = module.github_actions_oidc.aws_iam_roles["br3ndonland-infrastructure-live"].name
  policy_arn = aws_iam_policy.github_actions_oidc_provisioning.arn
}

data "aws_iam_policy_document" "s3_bucket_access_for_repo_with_oidc" {
  for_each = local.github_repos
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${each.key}", "arn:aws:s3:::${each.value.repo}"]
    sid       = "S3BucketListActions"
  }
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${each.key}/*", "arn:aws:s3:::${each.value.repo}/*"]
    sid       = "S3ObjectReadActions"
  }
  statement {
    actions   = ["s3:DeleteObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${each.key}/*", "arn:aws:s3:::${each.value.repo}/*"]
    sid       = "S3ObjectWriteActions"
  }
}

resource "aws_iam_policy" "s3_bucket_access_for_repo_with_oidc" {
  for_each    = local.github_repos
  name        = "github-actions-s3-${each.value.repo}"
  description = "Allows access to a single S3 bucket with the given name"
  policy      = data.aws_iam_policy_document.s3_bucket_access_for_repo_with_oidc[each.key].json
}

resource "aws_iam_role_policy_attachment" "s3_bucket_access_for_repo_with_oidc" {
  for_each   = aws_iam_policy.s3_bucket_access_for_repo_with_oidc
  role       = module.github_actions_oidc.aws_iam_roles[each.key].name
  policy_arn = each.value.arn
}
