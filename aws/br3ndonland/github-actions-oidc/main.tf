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
  source       = "github.com/br3ndonland/tofu-aws-github-actions-oidc"
  github_repos = var.github_repos_with_oidc
}

data "aws_iam_policy_document" "github_actions_oidc_provisioning" {
  statement {
    actions = [
      "iam:AddClientIDToOpenIDConnectProvider",
      "iam:CreateOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:UpdateOpenIDConnectProviderThumbprint",
    ]
    resources = ["arn:aws:iam::*:oidc-provider/token.actions.githubusercontent.com"]
    sid       = "IAMOIDCProviderProvisioningActions"
  }
  statement {
    actions = [
      "iam:GetOpenIDConnectProvider",
      "iam:ListOpenIDConnectProviders",
      "iam:ListOpenIDConnectProviderTags",
    ]
    resources = ["*"]
    sid       = "IAMOIDCProviderReadActions"
  }
  statement {
    actions = [
      "iam:DeleteOpenIDConnectProvider",
      "iam:RemoveClientIDFromOpenIDConnectProvider",
      "iam:UntagOpenIDConnectProvider",
    ]
    resources = ["arn:aws:iam::*:oidc-provider/token.actions.githubusercontent.com"]
    sid       = "IAMOIDCProviderCleanupActions"
  }
  statement {
    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
    ]
    resources = ["arn:aws:iam::*:policy/github*"]
    sid       = "IAMPolicyProvisioningActions"
  }
  statement {
    actions = [
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListEntitiesForPolicy",
      "iam:ListPolicies",
      "iam:ListPolicyVersions",
      "iam:ListUserPolicies",
    ]
    resources = ["*"]
    sid       = "IAMPolicyReadActions"
  }
  statement {
    actions   = ["iam:DeletePolicy", "iam:DeletePolicyVersion"]
    resources = ["arn:aws:iam::*:policy/github*"]
    sid       = "IAMPolicyCleanupActions"
  }
  statement {
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:PutRolePolicy",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
      "iam:UpdateAssumeRolePolicy",
    ]
    resources = ["arn:aws:iam::*:role/github*"]
    sid       = "IAMRoleProvisioningActions"
  }
  statement {
    actions = [
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:ListRoles",
    ]
    resources = ["*"]
    sid       = "IAMRoleReadActions"
  }
  statement {
    actions = [
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
    ]
    resources = ["arn:aws:iam::*:role/github*"]
    sid       = "IAMRoleCleanupActions"
  }
}

resource "aws_iam_policy" "github_actions_oidc_provisioning" {
  description = "Allows provisioning of resources for GitHub Actions OIDC (OpenID Connect)."
  name        = "github-actions-oidc-provisioning"
  policy      = data.aws_iam_policy_document.github_actions_oidc_provisioning.json
}

data "aws_iam_policy_document" "s3_bucket_for_oidc" {
  for_each = local.github_repos
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${each.key}", "arn:aws:s3:::${each.value.repo}"]
  }
  statement {
    actions   = ["s3:DeleteObject", "s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${each.key}/*", "arn:aws:s3:::${each.value.repo}/*"]
  }
}

resource "aws_iam_policy" "s3_bucket_for_oidc" {
  for_each    = local.github_repos
  name        = "github-actions-s3-${each.value.repo}"
  description = "Allows access to a single S3 bucket with the given name"
  policy      = data.aws_iam_policy_document.s3_bucket_for_oidc[each.key].json
}

resource "aws_iam_role_policy_attachment" "s3_bucket_for_oidc" {
  for_each   = aws_iam_policy.s3_bucket_for_oidc
  role       = module.github_actions_oidc.aws_iam_roles[each.key].name
  policy_arn = each.value.arn
}
