resource "spacelift_space" "in_root_space" {
  for_each = {
    for key, value in data.terraform_remote_state.spacelift_oidc.outputs.aws_iam_roles_for_spacelift_oidc :
    key => value if value.spacelift_space != "root"
  }
  inherit_entities = false
  name             = each.value.spacelift_space
  parent_space_id  = "root"
}
