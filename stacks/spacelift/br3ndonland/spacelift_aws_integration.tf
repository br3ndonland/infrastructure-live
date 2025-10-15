resource "spacelift_aws_integration" "oidc" {
  for_each = data.terraform_remote_state.spacelift_oidc.outputs.aws_iam_roles_for_spacelift_oidc
  name     = "${each.value.aws_account_alias}-${each.value.spacelift_space}"
  role_arn = each.value.aws_iam_role.arn
  space_id = spacelift_space.in_child_of_root_space[each.key].id
}
