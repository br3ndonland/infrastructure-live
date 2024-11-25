variable "owner" {
  description = "GitHub owner (user or organization) for the workspace"
  type        = string
}

variable "token" {
  description = "GitHub Personal Access Token (PAT) for org admin"
  sensitive   = true
  type        = string
}

variable "organization_settings" {
  description = "GitHub organization settings"
  type = map(object({
    advanced_security             = optional(bool, false)
    billing_email                 = string
    default_repository_permission = optional(string, "none")
  }))
  default = {}
}

variable "repos" {
  description = "Map of configuration attributes for each github_repository resource"
  type = map(map(object({
    name                            = string
    visibility                      = string
    description                     = optional(string)
    gitignore_template              = optional(string)
    is_repo_template                = optional(bool, false)
    from_repo_template              = optional(string)
    topics                          = optional(list(string))
    allow_merge_commit              = optional(bool, false)
    allow_rebase_merge              = optional(bool, false)
    allow_squash_merge              = optional(bool, true)
    enable_github_pages             = optional(bool, false)
    github_pages_cname              = optional(string)
    has_discussions                 = optional(bool, false)
    has_issues                      = optional(bool, false)
    has_vulnerability_alerts        = optional(bool)
    homepage_url                    = optional(string)
    default_branch_name             = optional(string, "main")
    protected_branch_names          = optional(list(string))
    required_approving_review_count = optional(map(number))
    required_deployments            = optional(map(list(string)))
    required_signatures             = optional(map(bool))
    required_status_checks = optional(map(list(object({
      context        = string
      integration_id = optional(number, 0)
    }))))
  })))
  default = {
    br3ndonland = {
      "br3ndonland.github.io" = {
        name                   = "br3ndonland.github.io"
        visibility             = "public"
        description            = "My personal website, built with Astro 🚀"
        enable_github_pages    = true
        homepage_url           = "https://www.bws.bio"
        protected_branch_names = ["main"]
        required_signatures    = { main = true }
      }
      br3ndonland = {
        name                   = "br3ndonland"
        visibility             = "public"
        description            = "GitHub profile repo 💪 🤓 ☕"
        homepage_url           = "https://github.com/br3ndonland"
        topics                 = ["profile-readme"]
        protected_branch_names = ["main"]
        required_signatures    = { main = true }
      }
      dotfiles = {
        name                   = "dotfiles"
        visibility             = "public"
        description            = "Computer setup and settings. Apple Silicon ready."
        protected_branch_names = ["main"]
        required_signatures    = { main = true }
        required_status_checks = {
          main = [
            { context = "check (macos-latest)", integration_id = 15368 },
            { context = "check (ubuntu-latest)", integration_id = 15368 },
          ]
        }
      }
      fastenv = {
        name               = "fastenv"
        visibility         = "public"
        description        = "⚙️ Unified environment variable and settings management for FastAPI and beyond 🚀"
        has_discussions    = true
        homepage_url       = "https://fastenv.bws.bio"
        from_repo_template = "br3ndonland/template-python"
        topics = [
          "python",
          "settings",
          "dotenv",
          "s3",
          "s3-bucket",
          "environment-variables",
          "configuration-management",
          "object-storage",
          "asgi",
          "s3-client",
          "uvicorn",
          "starlette",
          "pydantic",
          "fastapi",
          "anyio",
        ]
        default_branch_name = "develop"
        protected_branch_names = [
          "develop",
          "main",
        ]
        required_signatures = {
          develop = true
          main    = true
        }
        required_status_checks = {
          main = [
            { context = "analyze", integration_id = 15368 },
            { context = "ci (3.12)", integration_id = 15368 },
            { context = "Vercel", integration_id = 8329 },
          ]
          develop = [
            { context = "analyze", integration_id = 15368 },
            { context = "ci (3.12)", integration_id = 15368 },
            { context = "CodeQL", integration_id = 0 },
            { context = "Vercel", integration_id = 8329 },
          ]
        }
      }
      golearn = {
        name                   = "golearn"
        visibility             = "public"
        description            = "Resources from learning Go"
        topics                 = ["go", "golang", "course", "tutorial", "testing"]
        protected_branch_names = ["main"]
        required_signatures    = { main = true }
      }
      inboard = {
        name               = "inboard"
        visibility         = "public"
        description        = "🚢 Docker images and utilities to power your Python APIs and help you ship faster. With support for Uvicorn, Gunicorn, Starlette, and FastAPI."
        has_discussions    = true
        homepage_url       = "https://inboard.bws.bio"
        from_repo_template = "br3ndonland/template-python"
        topics = [
          "python",
          "docker",
          "hatch",
          "poetry",
          "gunicorn",
          "actions",
          "asgi",
          "uvicorn",
          "starlette",
          "fastapi",
          "github-packages",
          "python-poetry",
          "github-container-registry",
          "ghcr",
        ]
        default_branch_name = "develop"
        protected_branch_names = [
          "develop",
          "main",
        ]
        required_signatures = {
          develop = true
          main    = true
        }
        required_status_checks = {
          develop = [
            { context = "analyze", integration_id = 15368 },
            { context = "CodeQL", integration_id = 0 },
            { context = "docker (alpine, 3.12)", integration_id = 15368 },
            { context = "docker (bookworm, 3.12)", integration_id = 15368 },
            { context = "docker (slim-bookworm, 3.12)", integration_id = 15368 },
            { context = "python (3.12)", integration_id = 15368 },
            { context = "Vercel", integration_id = 8329 },
          ]
          main = [
            { context = "analyze", integration_id = 15368 },
            { context = "docker (alpine, 3.12)", integration_id = 15368 },
            { context = "docker (bookworm, 3.12)", integration_id = 15368 },
            { context = "docker (slim-bookworm, 3.12)", integration_id = 15368 },
            { context = "python (3.12)", integration_id = 15368 },
            { context = "Vercel", integration_id = 8329 },
          ]
        }
      }
      r-guide = {
        name                = "R-guide"
        visibility          = "public"
        description         = "A quick reference guide and sample code for statistical programming in R"
        enable_github_pages = true
        homepage_url        = "https://br3ndonland.github.io/R-guide"
        topics = [
          "r",
          "rmarkdown",
          "rstudio",
          "science",
          "statistics",
        ]
        protected_branch_names = ["main"]
        required_signatures    = { main = true }
        required_status_checks = {
          main = [
            { context = "build", integration_id = 15368 },
          ]
        }
      }
      template-python = {
        name                   = "template-python"
        visibility             = "public"
        description            = "Template repository for Python projects"
        has_discussions        = true
        is_repo_template       = true
        protected_branch_names = ["main"]
        required_signatures    = { develop = true, main = true }
        required_status_checks = {
          main = [
            { context = "ci (3.12)", integration_id = 15368 }
          ]
        }
      }
      tofu-aws-github-actions-oidc = {
        name                   = "tofu-aws-github-actions-oidc"
        visibility             = "public"
        description            = "OpenTofu module for connecting GitHub Actions and AWS with OIDC"
        protected_branch_names = ["main"]
        required_signatures    = { main = true }
        required_status_checks = {
          main = [
            { context = "check", integration_id = 15368 }
          ]
        }
      }
      terraform-examples = {
        name                   = "terraform-examples"
        visibility             = "public"
        description            = "Example Terraform configurations"
        protected_branch_names = ["main"]
        required_signatures    = { main = true }
        required_status_checks = {
          main = [
            { context = "check", integration_id = 15368 }
          ]
        }
      }
    }
  }
}

variable "outside_collaborators" {
  description = "GitHub organization outside collaborators"
  type = map(map(object({
    permission = optional(string, "push")
    repository = string
    username   = string
  })))
  default = {}
}
