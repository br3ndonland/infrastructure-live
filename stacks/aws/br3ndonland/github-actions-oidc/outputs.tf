output "github_actions_oidc_provisioning_policy" {
  value = {
    for key, value in aws_iam_policy.github_actions_oidc_provisioning :
    key => value if key != "attachment_count"
  }
}
