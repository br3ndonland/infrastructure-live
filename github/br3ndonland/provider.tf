provider "github" {
  owner = var.owner
  token = var.token != null ? var.token : data.onepassword_item.github_token.password
}

provider "onepassword" {
  service_account_token = var.op_service_account_token
}
