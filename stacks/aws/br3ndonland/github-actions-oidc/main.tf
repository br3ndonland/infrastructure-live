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
  source  = "br3ndonland/github-actions-oidc/aws"
  version = ">= 0.8.0"
  aws_iam_role_names = {
    "br3ndonland/infrastructure-live" = {
      "github-actions-oidc-br3ndonland-infrastructure-live-read" = ["*"],
      "github-actions-oidc-br3ndonland-infrastructure-live-write" = [
        "environment:github-actions/write",
        "ref:refs/heads/main",
        "ref_type:tag"
      ],
    }
  }
  github_repos = var.github_repos_with_oidc
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr_public" {
  for_each = {
    for key, value in module.github_actions_oidc["aws_iam_roles"] :
    key => value if strcontains(key, "infrastructure-live")
  }
  policy_arn = join("", [
    "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublic",
    strcontains(each.key, "read") ? "ReadOnly" : "PowerUser",
  ])
  role = each.value.name
}

resource "aws_iam_role_policy_attachment" "github_actions_oidc_provisioning" {
  role = module.github_actions_oidc.aws_iam_roles[
    "br3ndonland-infrastructure-live-github-actions-oidc-br3ndonland-infrastructure-live-write"
  ].name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/github-actions-oidc-provisioning"
  # policy resource moved to spacelift-oidc stack
}

data "aws_iam_policy_document" "s3_bucket_read_access_for_repo_with_oidc" {
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
}

resource "aws_iam_policy" "s3_bucket_read_access_for_repo_with_oidc" {
  for_each    = local.github_repos
  name        = "github-actions-s3-${each.value.repo}-read"
  description = "Allows access to a single S3 bucket with the given name"
  policy      = data.aws_iam_policy_document.s3_bucket_read_access_for_repo_with_oidc[each.key].json
}

resource "aws_iam_role_policy_attachment" "s3_bucket_read_access_for_repo_with_oidc" {
  for_each = {
    for key, value in module.github_actions_oidc.aws_iam_roles :
    key => value if strcontains(key, "read")
  }
  policy_arn = aws_iam_policy.s3_bucket_read_access_for_repo_with_oidc[replace(each.value.repo, "/", "-")].arn
  role       = each.value.name
}

data "aws_iam_policy_document" "s3_bucket_write_access_for_repo_with_oidc" {
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

resource "aws_iam_policy" "s3_bucket_write_access_for_repo_with_oidc" {
  for_each    = local.github_repos
  name        = "github-actions-s3-${each.value.repo}"
  description = "Allows access to a single S3 bucket with the given name"
  policy      = data.aws_iam_policy_document.s3_bucket_write_access_for_repo_with_oidc[each.key].json
}

resource "aws_iam_role_policy_attachment" "s3_bucket_write_access_for_repo_with_oidc" {
  for_each = {
    for key, value in module.github_actions_oidc.aws_iam_roles :
    key => value if strcontains(key, "write") || strcontains(key, "fastenv")
  }
  policy_arn = aws_iam_policy.s3_bucket_write_access_for_repo_with_oidc[replace(each.value.repo, "/", "-")].arn
  role       = each.value.name
}
