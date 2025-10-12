moved {
  from = github_branch_default.default["r-guide"]
  to   = github_branch_default.default["R-guide"]
}

moved {
  from = github_repository.repo["r-guide"]
  to   = github_repository.repo["R-guide"]
}

moved {
  from = github_branch_default.default["tofu-aws-github-actions-oidc"]
  to   = github_branch_default.default["terraform-aws-github-actions-oidc"]
}

moved {
  from = github_repository.repo["tofu-aws-github-actions-oidc"]
  to   = github_repository.repo["terraform-aws-github-actions-oidc"]
}

moved {
  from = github_repository_ruleset.branches["tofu-aws-github-actions-oidc"]
  to   = github_repository_ruleset.branches["terraform-aws-github-actions-oidc"]
}

moved {
  from = github_repository_ruleset.tags["tofu-aws-github-actions-oidc"]
  to   = github_repository_ruleset.tags["terraform-aws-github-actions-oidc"]
}
