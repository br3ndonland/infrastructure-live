locals {
  github_repos = {
    for repo in var.github_repos_with_oidc :
    replace(repo, "/", "-") => {
      owner = split("/", repo)[0]
      repo  = split("/", repo)[1]
    }
  }
}

module "github_actions_oidc" {
  source       = "github.com/br3ndonland/tofu-aws-github-actions-oidc"
  github_repos = var.github_repos_with_oidc
}

data "aws_iam_policy_document" "s3_bucket_for_oidc" {
  for_each = local.github_repos
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${each.value.repo}"]
  }
  statement {
    actions   = ["s3:DeleteObject", "s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${each.value.repo}/*"]
  }
}

resource "aws_iam_policy" "s3_bucket_for_oidc" {
  for_each    = local.github_repos
  name        = "github-actions-s3-${each.value.repo}"
  description = "Allows access to a single S3 bucket with the given name"
  policy      = data.aws_iam_policy_document.s3_bucket_for_oidc[each.key].json
}

resource "aws_iam_role_policy_attachment" "s3_bucket_for_oidc" {
  for_each   = aws_iam_policy.s3_bucket_for_oidc
  role       = module.github_actions_oidc.aws_iam_roles[each.key].name
  policy_arn = each.value.arn
}
