resource "spacelift_role_attachment" "admin" {
  for_each = spacelift_space.in_root_space
  role_id  = var.spacelift_space_admin_role_id
  space_id = each.value.id
  stack_id = spacelift_stack.spacelift-br3ndonland.id
}
