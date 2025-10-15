resource "spacelift_stack" "aws-br3ndonland-github-actions-oidc" {
  additional_project_globs         = null
  administrative                   = false
  allow_run_promotion              = false
  autodeploy                       = true
  branch                           = var.github_branch_default
  enable_local_preview             = true
  enable_well_known_secret_masking = true
  labels                           = ["aws", "github"]
  manage_state                     = false
  name                             = "aws-br3ndonland-github-actions-oidc"
  project_root                     = "stacks/aws/br3ndonland/github-actions-oidc"
  protect_from_deletion            = false
  repository                       = var.github_repo
  space_id                         = spacelift_space.in_root_space["br3ndonland-aws"].id
  terraform_workflow_tool          = "OPEN_TOFU"
  terraform_version                = var.opentofu_version
}

resource "spacelift_stack" "aws-br3ndonland-spacelift-oidc" {
  additional_project_globs         = ["modules/aws-spacelift-oidc"]
  administrative                   = false
  allow_run_promotion              = false
  autodeploy                       = true
  branch                           = var.github_branch_default
  enable_local_preview             = true
  enable_well_known_secret_masking = true
  labels                           = ["aws", "spacelift"]
  manage_state                     = false
  name                             = "aws-br3ndonland-spacelift-oidc"
  project_root                     = "stacks/aws/br3ndonland/spacelift-oidc"
  protect_from_deletion            = false
  repository                       = var.github_repo
  space_id                         = spacelift_space.in_root_space["br3ndonland-aws"].id
  terraform_workflow_tool          = "OPEN_TOFU"
  terraform_version                = var.opentofu_version
}

resource "spacelift_stack" "github-br3ndonland" {
  additional_project_globs         = null
  administrative                   = false
  allow_run_promotion              = false
  autodeploy                       = true
  branch                           = var.github_branch_default
  enable_local_preview             = true
  enable_well_known_secret_masking = true
  manage_state                     = false
  labels                           = ["github"]
  name                             = "github-br3ndonland"
  project_root                     = "stacks/github/br3ndonland"
  protect_from_deletion            = true
  repository                       = var.github_repo
  space_id                         = spacelift_space.in_root_space["br3ndonland-github"].id
  terraform_workflow_tool          = "OPEN_TOFU"
  terraform_version                = var.opentofu_version
}

resource "spacelift_stack" "spacelift-br3ndonland" {
  additional_project_globs         = null
  administrative                   = true
  allow_run_promotion              = false
  autodeploy                       = true
  branch                           = var.github_branch_default
  enable_local_preview             = true
  enable_well_known_secret_masking = true
  labels                           = ["spacelift"]
  manage_state                     = false
  name                             = "spacelift-br3ndonland"
  project_root                     = "stacks/spacelift/br3ndonland"
  protect_from_deletion            = true
  repository                       = var.github_repo
  space_id                         = spacelift_space.in_root_space["br3ndonland-spacelift"].id
  terraform_workflow_tool          = "OPEN_TOFU"
  terraform_version                = var.opentofu_version
}
