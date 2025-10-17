resource "spacelift_context" "space" {
  for_each    = spacelift_space.in_root_space
  description = "Context for ${each.value.name} space"
  labels      = ["autoattach:*"]
  name        = each.key
  space_id    = each.value.id
}
