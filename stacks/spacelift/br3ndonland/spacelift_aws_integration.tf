resource "spacelift_aws_integration" "external_id" {
  for_each           = data.terraform_remote_state.spacelift.outputs.aws_iam_roles_for_spacelift
  autoattach_enabled = true
  labels             = ["autoattach:*"]
  name               = "${each.key}-external-id"
  role_arn           = each.value.aws_iam_role_external_id.arn
  space_id           = spacelift_space.in_root_space[each.key].id
}

resource "spacelift_aws_integration" "oidc" {
  for_each = data.terraform_remote_state.spacelift.outputs.aws_iam_roles_for_spacelift
  name     = "${each.key}-oidc"
  role_arn = each.value.aws_iam_role_oidc.arn
  space_id = spacelift_space.in_root_space[each.key].id
}
