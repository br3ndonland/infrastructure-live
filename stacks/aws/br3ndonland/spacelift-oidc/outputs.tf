output "aws_iam_roles_for_spacelift_oidc" {
  description = "ARNs and names of AWS IAM roles that have been provisioned for Spacelift OIDC"
  value       = local.aws_iam_roles_for_spacelift_oidc
}

output "github_actions_oidc_provisioning_policy" {
  value = {
    for key, value in aws_iam_policy.github_actions_oidc_provisioning :
    key => value if key != "attachment_count"
  }
}
