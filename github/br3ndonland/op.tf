data "onepassword_item" "github_token" {
  vault = var.op_vault
  uuid  = var.op_vault_item_github_token
}
