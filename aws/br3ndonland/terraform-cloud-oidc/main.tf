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
