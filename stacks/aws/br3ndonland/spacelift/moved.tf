moved {
  from = aws_iam_role_policy_attachment.github_actions_oidc_provisioning["br3ndonland"]
  to   = aws_iam_role_policy_attachment.github_actions_oidc_provisioning_for_oidc_role["br3ndonland-aws"]
}

moved {
  from = aws_iam_role_policy_attachment.spacelift_oidc_provisioning["br3ndonland"]
  to   = aws_iam_role_policy_attachment.spacelift_oidc_provisioning_for_oidc_role["br3ndonland-aws"]
}

moved {
  from = aws_iam_role_policy_attachment.spacelift_oidc_power_user["br3ndonland"]
  to   = aws_iam_role_policy_attachment.spacelift_oidc_power_user["br3ndonland-aws"]
}

moved {
  from = aws_iam_policy.s3_backend_bucket_access_for_spacelift_space["aws"]
  to   = aws_iam_policy.s3_backend_bucket_access_for_spacelift_space["br3ndonland-aws"]
}

moved {
  from = aws_iam_policy.s3_backend_bucket_access_for_spacelift_space["github"]
  to   = aws_iam_policy.s3_backend_bucket_access_for_spacelift_space["br3ndonland-github"]
}

moved {
  from = aws_iam_policy.s3_backend_bucket_access_for_spacelift_space["spacelift"]
  to   = aws_iam_policy.s3_backend_bucket_access_for_spacelift_space["br3ndonland-spacelift"]
}

moved {
  from = aws_iam_role_policy_attachment.s3_backend_bucket_access_for_spacelift_space
  to   = aws_iam_role_policy_attachment.s3_backend_bucket_access_for_spacelift_space_for_oidc_role
}

moved {
  from = aws_iam_role_policy_attachment.s3_backend_bucket_access_for_aws_remote_state
  to   = aws_iam_role_policy_attachment.s3_backend_bucket_access_for_aws_remote_state_for_oidc_role
}
