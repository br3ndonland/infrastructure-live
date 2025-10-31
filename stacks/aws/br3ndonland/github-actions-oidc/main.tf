locals {
  github_repos = {
    for repo in var.github_repos_with_oidc :
    replace(repo, "/", "-") => {
      owner = split("/", repo)[0]
      repo  = split("/", repo)[1]
    }
  }
}

data "aws_caller_identity" "current" {}

module "github_actions_oidc" {
  source       = "br3ndonland/github-actions-oidc/aws"
  version      = ">= 0.7.0"
  github_repos = var.github_repos_with_oidc
}

resource "aws_iam_role_policy_attachment" "github_actions_oidc_provisioning" {
  role       = module.github_actions_oidc.aws_iam_roles["br3ndonland-infrastructure-live"].name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/github-actions-oidc-provisioning"
  # policy resource moved to spacelift-oidc stack
}

data "aws_iam_policy_document" "s3_bucket_access_for_repo_with_oidc" {
  for_each = local.github_repos
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${each.key}", "arn:aws:s3:::${each.value.repo}"]
    sid       = "S3BucketListActions"
  }
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${each.key}/*", "arn:aws:s3:::${each.value.repo}/*"]
    sid       = "S3ObjectReadActions"
  }
  statement {
    actions   = ["s3:DeleteObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${each.key}/*", "arn:aws:s3:::${each.value.repo}/*"]
    sid       = "S3ObjectWriteActions"
  }
}

resource "aws_iam_policy" "s3_bucket_access_for_repo_with_oidc" {
  for_each    = local.github_repos
  name        = "github-actions-s3-${each.value.repo}"
  description = "Allows access to a single S3 bucket with the given name"
  policy      = data.aws_iam_policy_document.s3_bucket_access_for_repo_with_oidc[each.key].json
}

resource "aws_iam_role_policy_attachment" "s3_bucket_access_for_repo_with_oidc" {
  for_each   = aws_iam_policy.s3_bucket_access_for_repo_with_oidc
  role       = module.github_actions_oidc.aws_iam_roles[each.key].name
  policy_arn = each.value.arn
}
