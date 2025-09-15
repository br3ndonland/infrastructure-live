/*
  This file helps ensure that OpenTofu is used consistently instead of HashiCorp Terraform.
  OpenTofu will give preference to the `versions.tofu` file over the `versions.tf` file, but
  HashiCorp Terraform will read `versions.tf` and error when it can't find the required version.
  The idea is to enforce use of OpenTofu by raising an error if Terraform is used instead.
  https://opentofu.org/docs/language/files/
*/
terraform {
  required_version = "> 99"
}
