locals {
  tfc_workspaces = {
    for workspace in var.tfc_workspaces : lower(replace(workspace, "/", "-")) => {
      organization = split("/", workspace)[0]
      workspace    = split("/", workspace)[1]
    }
  }
}

module "terraform_cloud_oidc" {
  source         = "./modules/terraform-cloud-oidc"
  tfc_workspaces = var.tfc_workspaces
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

resource "aws_iam_role_policy_attachment" "github_actions_oidc_provisioning" {
  for_each = toset([
    for key in keys(local.tfc_workspaces) :
    key if strcontains(key, "github-actions-oidc")
  ])
  role       = module.terraform_cloud_oidc.aws_iam_roles[each.key].name
  policy_arn = aws_iam_policy.github_actions_oidc_provisioning.arn
}
