output "aws_iam_roles_for_spacelift_oidc" {
  description = "ARNs and names of AWS IAM roles that have been provisioned for Spacelift OIDC"
  value       = local.aws_iam_roles_for_spacelift_oidc
}
