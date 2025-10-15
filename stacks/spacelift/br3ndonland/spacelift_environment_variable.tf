resource "spacelift_environment_variable" "op_service_account_token" {
  name       = "TF_VAR_op_service_account_token"
  stack_id   = spacelift_stack.github-br3ndonland.id
  write_only = true

  lifecycle {
    ignore_changes = [value]
  }
}

resource "spacelift_environment_variable" "op_vault" {
  name       = "TF_VAR_op_vault"
  stack_id   = spacelift_stack.github-br3ndonland.id
  write_only = false

  lifecycle {
    ignore_changes = [value]
  }
}

resource "spacelift_environment_variable" "op_vault_item_github_token" {
  name       = "TF_VAR_op_vault_item_github_token"
  stack_id   = spacelift_stack.github-br3ndonland.id
  write_only = false

  lifecycle {
    ignore_changes = [value]
  }
}
