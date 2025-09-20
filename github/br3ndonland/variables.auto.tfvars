repos = {
  br3ndonland = {
    "br3ndonland.github.io" = {
      visibility             = "public"
      description            = "My personal website, built with Astro 🚀"
      enable_github_pages    = true
      homepage_url           = "https://www.bws.bio"
      protected_branch_names = ["main"]
      required_signatures = {
        branches = true
        tags     = true
      }
      required_status_checks = {
        branches = {
          "Build"  = 15368
          "Vercel" = 8329
        }
        tags = {
          "Build"                  = 15368
          "Deploy to GitHub Pages" = 15368
          "Vercel"                 = 8329
        }
      }
    }
    br3ndonland = {
      visibility             = "public"
      description            = "GitHub profile repo 💪 🤓 ☕"
      homepage_url           = "https://github.com/br3ndonland"
      topics                 = ["profile-readme"]
      protected_branch_names = ["main"]
      required_signatures = {
        branches = true
        tags     = true
      }
    }
    dotfiles = {
      visibility             = "public"
      description            = "Computer setup and settings. Apple Silicon ready."
      topics                 = ["apple-silicon", "dotfiles", "homebrew", "m1", "macos", "strap"]
      protected_branch_names = ["main"]
      required_signatures = {
        branches = true
        tags     = true
      }
      required_status_checks = {
        branches = {
          "check (macos-14)"      = 15368
          "check (ubuntu-latest)" = 15368
        }
        tags = {
          "check (macos-14)"      = 15368
          "check (ubuntu-latest)" = 15368
        }
      }
    }
    dovi_tool = {
      visibility             = "public"
      description            = "Container image that can be used to run dovi_tool"
      has_discussions        = true
      topics                 = ["dolby-vision", "dovi"]
      protected_branch_names = ["main"]
      required_signatures = {
        branches = true
        tags     = true
      }
    }
    fastenv = {
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
      protected_branch_names = ["main"]
      required_signatures = {
        branches = true
        tags     = true
      }
      required_status_checks = {
        branches = {
          "ci (3.12)" = 15368
          "Vercel"    = 8329
        }
        tags = {
          "ci (3.12)" = 15368
          "Vercel"    = 8329
        }
      }
    }
    golearn = {
      visibility             = "public"
      description            = "Resources from learning Go"
      topics                 = ["go", "golang", "course", "tutorial", "testing"]
      protected_branch_names = ["main"]
      required_signatures = {
        branches = true
        tags     = true
      }
    }
    inboard = {
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
      default_branch_name    = "develop"
      protected_branch_names = ["develop", "main"]
      required_signatures = {
        branches = true
        tags     = true
      }
      required_status_checks = {
        branches = {
          "docker (alpine, 3.12)"        = 15368
          "docker (bookworm, 3.12)"      = 15368
          "docker (slim-bookworm, 3.12)" = 15368
          "python (3.12)"                = 15368
          "Vercel"                       = 8329
        }
        tags = {
          "docker (alpine, 3.12)"        = 15368
          "docker (bookworm, 3.12)"      = 15368
          "docker (slim-bookworm, 3.12)" = 15368
          "python (3.12)"                = 15368
          "Vercel"                       = 8329
        }
      }
    }
    R-guide = {
      visibility             = "public"
      description            = "A quick reference guide and sample code for statistical programming in R"
      enable_github_pages    = true
      github_pages_path      = "/docs"
      homepage_url           = "https://br3ndonland.github.io/R-guide"
      topics                 = ["r", "rmarkdown", "rstudio", "science", "statistics"]
      protected_branch_names = ["main"]
      required_signatures = {
        branches = true
        tags     = true
      }
      required_status_checks = {
        branches = {
          build = 15368
        }
        tags = {
          build = 15368
        }
      }
    }
    template-python = {
      visibility             = "public"
      description            = "Template repository for Python projects"
      has_discussions        = true
      is_repo_template       = true
      protected_branch_names = ["main"]
      required_signatures = {
        branches = true
        tags     = true
      }
      required_status_checks = {
        branches = {
          "ci (3.13)" = 15368
        }
        tags = {
          "ci (3.13)" = 15368
        }
      }
    }
    tofu-aws-github-actions-oidc = {
      visibility             = "public"
      description            = "OpenTofu module for connecting GitHub Actions and AWS with OIDC"
      protected_branch_names = ["main"]
      required_signatures = {
        branches = true
        tags     = true
      }
      required_status_checks = {
        branches = {
          check = 15368
        }
        tags = {
          check = 15368
        }
      }
    }
    terraform-examples = {
      visibility             = "public"
      description            = "Example Terraform configurations"
      protected_branch_names = ["main"]
      required_signatures = {
        branches = true
        tags     = true
      }
      required_status_checks = {
        branches = {
          check = 15368
        }
        tags = {
          check = 15368
        }
      }
    }
  }
}
