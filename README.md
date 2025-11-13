# infrastructure-live

## Description

This repo contains cloud infrastructure configurations written with [OpenTofu](https://opentofu.org/).

The name "infrastructure-live" comes from the [Gruntwork paradigm](https://docs.gruntwork.io/guides/build-it-yourself/achieve-compliance/deployment-walkthrough/prepare-your-infrastructure-live-repository/).

[OpenTofu state](https://opentofu.org/docs/language/state/) is stored using the [S3 backend](https://opentofu.org/docs/language/settings/backends/s3/) with [native S3 state locking](https://opentofu.org/docs/language/settings/backends/s3/#s3-state-locking). The S3 bucket used for state was provisioned outside of OpenTofu. OpenTofu configurations typically do not manage the bucket containing their own state.

The configurations run on [Spacelift](https://docs.spacelift.io/).

## Stacks

### AWS

These stacks are mostly used to configure OpenID Connect (OIDC). OIDC allows workflows to authenticate with AWS by assuming IAM roles that grant temporary security credentials. See the [module](https://github.com/br3ndonland/terraform-aws-github-actions-oidc) used in the stacks for more details.

### GitHub

This stack uses the [GitHub OpenTofu provider](https://search.opentofu.org/provider/integrations/github/latest) to manage GitHub resources.

See the [GitHub stack README](./stacks/github/br3ndonland/README.md) for more details.

### Spacelift

This stack is used for [Spacelift](https://docs.spacelift.io/) administration.

The setup process goes like this:

1. Sign up for Spacelift by connecting a GitHub account.
2. [Install the Spacelift GitHub app](https://docs.spacelift.io/getting-started/integrate-source-code/GitHub) on the GitHub account.
   - The GitHub Marketplace app should be fine.
   - A custom GitHub app is only needed when managing multiple GitHub accounts or for [GitHub Enterprise](https://docs.github.com/en/get-started/learning-about-github/githubs-plans#github-enterprise).
3. Provision AWS IAM roles for Spacelift.
   - The roles are provisioned using [a stack in this repo](./stacks/aws/br3ndonland/spacelift-oidc/main.tf). This presents a "[chicken-and-egg](https://en.wikipedia.org/wiki/Chicken_or_the_egg)" problem - the configurations will provision roles for all stacks to use, but the roles will not exist until the configurations are applied - so how do these configurations themselves get credentials? One solution is to apply the configurations locally or with static AWS access key credentials the first time to provision the roles that will be used in later applies.
   - It can be helpful to provision separate read and write roles. Read roles are for running OpenTofu plans on PRs, and would only have permissions to read state, whereas write roles have permissions to write to the state file and perform any other operations specified in the OpenTofu configurations. [GitHub deployment environments](https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments) can be used to select one role or the other. For example, the write role have a deployment environment that can only be used by default branch or by tags. Deployment environments must be selected at the job level before the job begins, so it can be helpful to create a setup job that selects the appropriate deployment environment and passes it to other jobs. Each use of a deployment environment creates a "deployment" (even if nothing is actually deployed) that can be either active or inactive. GitHub Actions auto-inactivates deployments, and although this behavior is not configurable or documented, there are some possible workarounds/hacks suggested by a community discussion [comment](https://github.com/orgs/community/discussions/67982#discussioncomment-7086962).The workaround used in this repo is to provide each deployment with its own unique URL.
4. Use the AWS IAM roles to provision [integrations](https://docs.spacelift.io/integrations/cloud-providers) for each [Spacelift space](https://docs.spacelift.io/concepts/spaces).
   - "Integrations" are basically just ARNs of roles that can be assumed by Spacelift.
   - In order to specify the AWS integration role ARNs for each space, a [context](https://docs.spacelift.io/concepts/configuration/context) can be created for each space with the `autoattach:*` label. When a context is in a specific space, the `autoattach:*` label will attach it to only the stacks within that space and its child spaces ([docs](https://docs.spacelift.io/concepts/configuration/context#auto-attachments), [spacelift-io/user-documentation#816](https://github.com/spacelift-io/user-documentation/pull/816)). [Environment variables](https://docs.spacelift.io/concepts/configuration/environment) can then be added to each context specifying the AWS integration role ARNs.
   - Integrations are an awkward abstraction - they can be _set_ on spaces, but they can also be separately _attached_ to stacks. It's particularly awkward during [programmatic setup of integrations](https://docs.spacelift.io/integrations/cloud-providers/aws#programmatic-setup). [OIDC integrations](https://docs.spacelift.io/integrations/cloud-providers/oidc) alleviate some of this awkwardness because they don't have to be attached to specific stacks - OIDC subject claims can specify spaces and stacks for greater specificity.
   - [There is only limited support for custom OIDC subject claims](https://feedback.spacelift.io/p/allow-adding-space-hierarchy-in-oidc-subject). Note that `space:` claims must reference the space _id_, not the space name.
   - **Spacelift only offers OIDC on paid plans**. By comparison, HashiCorp allows [Terraform Cloud OIDC](https://developer.hashicorp.com/terraform/cloud-docs/dynamic-provider-credentials) on free plans.
   - The OIDC claims in this repo are customized to create dedicated OIDC roles for each space. The AWS space has broad privileges needed to manage AWS resources. The GitHub and Spacelift spaces have only the least privilege needed to read state for the S3 backend.
   - The role ARNs can be passed to the Spacelift provider configurations with [`terraform_remote_state` data sources](https://opentofu.org/docs/language/state/remote-state-data/), [Spacelift stack dependencies](https://docs.spacelift.io/concepts/stack/stack-dependencies), or another preferred method.
   - The Spacelift provider configurations present another chicken-and-egg problem - if role ARNs for Spacelift integrations are read from remote state, then reading remote state requires credentials from a role ARN. Again here, one solution is to apply the stack locally or with static credentials the first time.
5. Provision [stacks](https://docs.spacelift.io/concepts/stack) in each space.
   - Stacks are often viewed all together in the stacks view of the web UI, so it helps to have a descriptive name for each stack.
   - [Spacelift administrative stacks](https://docs.spacelift.io/concepts/stack/stack-settings#administrative) are only allowed to administrate the space that they're in. It can be helpful to either put administrative stacks in the `root` space or to generate an admin API key for the administrative stack so it can access all resources in the Spacelift account. Otherwise, its access may be limited by the space that the stack is in.
   - Spacelift is working on making administrative stack permissions more flexible with [stack role bindings](https://docs.spacelift.io/concepts/authorization/assigning-roles-stacks.html).
6. Build [custom runner images](https://docs.spacelift.io/integrations/docker#customizing-the-runner-image).
   - [Custom runner images](https://docs.spacelift.io/integrations/docker#customizing-the-runner-image) may be needed for certain stacks. For example, the [1Password CLI](https://developer.1password.com/docs/cli/get-started/) (`op`) is required if using the [1Password OpenTofu provider](https://developer.1password.com/docs/terraform/?workflow-type=1password-cli).
   - It would be simplest to install `op` in a `before_init` [stack hook](https://docs.spacelift.io/concepts/stack/stack-settings#customizing-workflow), but Spacelift runner images use a non-root user `spacelift` that cannot install apk repositories, so a custom image build is needed.
   - `op` does not support Alpine Linux on `arm64` (`aarch64`). If attempting to install `op` on `linux/arm64` with Alpine Linux and `apk`, the following warning may be seen: "WARNING: updating and opening https://downloads.1password.com/linux/alpinelinux/stable/: No such file or directory".
   - If using AWS [ECR Public](https://docs.aws.amazon.com/AmazonECR/latest/public/public-registries.html), note that only `us-east-1` is supported (see the [`ecrpublic_repository` resource](https://search.opentofu.org/provider/hashicorp/aws/latest/docs/resources/ecrpublic_repository) and
     [hashicorp/terraform-provider-aws#18047](https://github.com/hashicorp/terraform-provider-aws/issues/18047)). The ECR Public registry for each account is assigned a default alias that does not match the account alias. A custom alias can be requested, but it must be approved by AWS.
