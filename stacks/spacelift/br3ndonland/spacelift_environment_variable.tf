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

resource "spacelift_environment_variable" "s3_backend_bucket_role_arn" {
  for_each    = spacelift_aws_integration.oidc
  context_id  = spacelift_context.space[each.key].id
  description = "ARN of role used to access the OpenTofu S3 backend bucket"
  name        = "TF_VAR_s3_backend_bucket_role_arn"
  value       = each.value.role_arn
  write_only  = false
}

resource "spacelift_environment_variable" "s3_backend_bucket_web_identity_token_file" {
  for_each    = spacelift_aws_integration.oidc
  context_id  = spacelift_context.space[each.key].id
  description = "Path to OIDC web identity token file used to access the OpenTofu S3 backend bucket"
  name        = "TF_VAR_s3_backend_bucket_web_identity_token_file"
  value       = "/mnt/workspace/spacelift.oidc"
  write_only  = false
}

resource "spacelift_environment_variable" "SPACELIFT_API_KEY_ENDPOINT" {
  description = "Endpoint for API key used by Spacelift administrative stack"
  name        = "SPACELIFT_API_KEY_ENDPOINT"
  stack_id    = spacelift_stack.spacelift-br3ndonland.id
  value       = "https://${var.spacelift_organization}.app.spacelift.io"
  write_only  = false
}

resource "spacelift_environment_variable" "SPACELIFT_API_KEY_ID" {
  description = "ID of API key used by Spacelift administrative stack"
  name        = "SPACELIFT_API_KEY_ID"
  stack_id    = spacelift_stack.spacelift-br3ndonland.id
  write_only  = false

  lifecycle {
    ignore_changes = [value]
  }
}

resource "spacelift_environment_variable" "SPACELIFT_API_KEY_SECRET" {
  description = "Secret portion of API key used by Spacelift administrative stack"
  name        = "SPACELIFT_API_KEY_SECRET"
  stack_id    = spacelift_stack.spacelift-br3ndonland.id
  write_only  = true

  lifecycle {
    ignore_changes = [value]
  }
}
