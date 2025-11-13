locals {
  github_repository_ruleset_ids = {
    "br3ndonland.github.io" = {
      branches = 7936171
      tags     = 7936176
    }
    crp = {
      branches = 7935659
      tags     = 7935662
    }
    fastenv = {
      branches = 7935896
      tags     = 7935905
    }
    inboard = {
      branches = 7935911
      tags     = 7935929
    }
    infrastructure-live = {
      branches = 9377329
      tags     = 9377342
    }
    template-python = {
      branches = 7951421
      tags     = 7951424
    }
  }
}

import {
  for_each = {
    for key, value in var.repos[var.owner] :
    key => value if contains(keys(local.github_repository_ruleset_ids), key)
  }
  id = "${each.key}:${local.github_repository_ruleset_ids[each.key]["branches"]}"
  to = github_repository_ruleset.branches[each.key]
}

import {
  for_each = {
    for key, value in var.repos[var.owner] :
    key => value if contains(keys(local.github_repository_ruleset_ids), key)
  }
  id = "${each.key}:${local.github_repository_ruleset_ids[each.key]["tags"]}"
  to = github_repository_ruleset.tags[each.key]
}

import {
  id = "crp"
  to = github_repository.repo["crp"]
}

import {
  id = "crp"
  to = github_branch_default.default["crp"]
}

import {
  id = "infrastructure-live"
  to = github_repository.repo["infrastructure-live"]
}

import {
  id = "infrastructure-live"
  to = github_branch_default.default["infrastructure-live"]
}
