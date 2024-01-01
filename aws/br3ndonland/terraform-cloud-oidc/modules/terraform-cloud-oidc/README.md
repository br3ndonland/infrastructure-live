# Terraform Cloud OpenID Connect

## Description

[Credentials are required for the AWS Terraform provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication) so that Terraform can apply configurations. If using Terraform Cloud, credentials need to be provided there.

One way to provide credentials for Terraform Cloud is by creating AWS IAM users, creating AWS access keys for the users, and storing the access keys in Terraform Cloud workspace variables. AWS access keys are persistent credentials that require manual rotation.

Another way to provide credentials is through OpenID Connect (OIDC). OIDC allows Terraform runs to authenticate with AWS by assuming [IAM roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_terms-and-concepts.html) that grant temporary security credentials, instead of by using persistent AWS access key credentials. Terraform Cloud added support for assuming roles with OIDC in March 2023. See the [blog post](https://www.hashicorp.com/blog/dynamic-provider-credentials-now-ga-for-terraform-cloud), the [Terraform Cloud docs on dynamic provider credentials](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials), and the [tutorial on dynamic provider credentials](https://developer.hashicorp.com/terraform/tutorials/cloud/dynamic-credentials).

## Usage

There are two common use cases that this module supports:

1. Configuring credentials for a set of Terraform Cloud projects, with separate credentials for each project, and allowing credentials to be used by any workspace in the project. [Terraform Cloud project names](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/organize-workspaces-with-projects) can include "letters, numbers, inner spaces, dashes (`-`), and underscores (`_`)." Specify project names with `var.tfc_projects`.
2. Configuring credentials for a set of Terraform Cloud workspaces, with separate credentials for each workspace, and allowing the credentials to be used by only that specific workspace. [Terraform Cloud workspace names](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/creating) must be unique within the organization (across all projects) and can include "letters, numbers, dashes (`-`), and underscores (`_`)." Specify workspace names with `var.tfc_workspaces`.

- Configure a [backend](https://developer.hashicorp.com/terraform/language/settings/backends/configuration) for Terraform state.
- Set [Terraform input variables](https://developer.hashicorp.com/terraform/language/values/variables), either with variables set in a remote state workspace, by passing variable values in to the `terraform` CLI command directly with `-var`, or with a `.tfvars` file. Variable definitions files named `terraform.tfvars` or `*.auto.tfvars` will be loaded automatically. If using a variable definitions file with a different name, use `-var-file=filename.tfvars`.
- Next, declare Terraform configurations using the module.
- Then, [initialize and apply](https://developer.hashicorp.com/terraform/intro/core-workflow) the Terraform configuration.

## Code quality

- Terraform should be formatted with [`terraform fmt`](https://developer.hashicorp.com/terraform/cli/commands/fmt).
- Shell scripts should be formatted with [`shfmt`](https://github.com/mvdan/sh), with two space indentations (`shfmt -i 2 -w .`), and will also be checked for errors with [ShellCheck](https://github.com/koalaman/shellcheck) (`shellcheck **/*.sh -S error`).
- Other web code (JSON, Markdown, YAML) should be formatted with [Prettier](https://prettier.io/).
