locals {
  tfc_workspaces = {
    for workspace in var.tfc_workspaces : lower(replace(workspace, "/", "-")) => {
      organization = split("/", workspace)[0]
      workspace    = split("/", workspace)[1]
    }
  }
}

data "terraform_remote_state" "github_actions_oidc" {
  backend = "local"
  config = {
    path = "../github-actions-oidc/terraform.tfstate"
  }
}

module "terraform_cloud_oidc" {
  source         = "./modules/terraform-cloud-oidc"
  tfc_workspaces = var.tfc_workspaces
}

resource "aws_iam_role_policy_attachment" "github_actions_oidc_provisioning" {
  for_each = toset([
    for key in keys(local.tfc_workspaces) :
    key if strcontains(key, "github-actions-oidc")
  ])
  role       = module.terraform_cloud_oidc.aws_iam_roles[each.key].name
  policy_arn = data.terraform_remote_state.github_actions_oidc.outputs.github_actions_oidc_provisioning_policy.arn
}
