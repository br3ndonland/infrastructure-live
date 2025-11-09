/*
moved {
  from = module.github_actions_oidc
  to   = module.github_actions_oidc["write"]
}
*/

moved {
  from = aws_iam_policy.s3_bucket_access_for_repo_with_oidc
  to   = aws_iam_policy.s3_bucket_write_access_for_repo_with_oidc
}

moved {
  from = aws_iam_role_policy_attachment.s3_bucket_access_for_repo_with_oidc["br3ndonland-fastenv"]
  to   = aws_iam_role_policy_attachment.s3_bucket_write_access_for_repo_with_oidc["br3ndonland-fastenv"]
}
