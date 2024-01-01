variable "aws_provider_region" {
  type = string
}

variable "create_oidc_provider" {
  type    = bool
  default = true
}

variable "tfc_hostname" {
  type    = string
  default = "app.terraform.io"
}

variable "tfc_workspaces" {
  type = set(string)
}
