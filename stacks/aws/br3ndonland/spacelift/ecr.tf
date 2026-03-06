resource "aws_ecrpublic_repository" "spacelift_runner_terraform" {
  # ECR Public resources only support us-east-1.
  # https://search.opentofu.org/provider/hashicorp/aws/latest/docs/resources/ecrpublic_repository
  # https://github.com/hashicorp/terraform-provider-aws/issues/18047
  provider = aws.us_east_1

  repository_name = "spacelift-runner-terraform"
  catalog_data {
    about_text = join(" ", [
      "Spacelift OpenTofu/Terraform runner image",
      "([ECR](https://gallery.ecr.aws/spacelift/runner-terraform),",
      "[GitHub](https://github.com/spacelift-io/runner-terraform))",
      "with additional utilities, including the",
      "[1Password CLI](https://developer.1password.com/docs/cli/), which is required for the",
      "[1Password OpenTofu/Terraform provider](https://developer.1password.com/docs/terraform/).",
      "This image is only built for linux/amd64 (x86-64) because the 1Password CLI does not support arm64 (aarch64)."
    ])
    architectures     = ["x86-64"]
    description       = "Spacelift OpenTofu/Terraform runner image with additional utilities, including the 1Password CLI."
    operating_systems = ["Linux"]
    usage_text        = "See the Spacelift docs on [custom runner images](https://docs.spacelift.io/integrations/docker)."
  }
}

# This repository policy allows the write-enabled GitHub Actions OIDC role for this repo to publish images.
# The role and the ECR repo are in the same AWS account, so these permissions can also be conferred by
# attaching identity-based policies to the role.
data "aws_iam_policy_document" "spacelift_runner_terraform" {
  statement {
    actions = [
      "ecr-public:DescribeImageTags",
      "ecr-public:DescribeRegistries",
      "ecr-public:DescribeRepositories",
    ]
    sid = "ECRPublicListActions"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
  statement {
    actions = [
      "ecr-public:BatchCheckLayerAvailability",
      "ecr-public:DescribeImages",
      "ecr-public:GetAuthorizationToken",
      "ecr-public:GetRegistryCatalogData",
      "ecr-public:GetRepositoryCatalogData",
      "ecr-public:GetRepositoryPolicy",
      "ecr-public:ListTagsForResource",
    ]
    sid = "ECRReadActions"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
  statement {
    actions = [
      "ecr-public:TagResource",
      "ecr-public:UntagResource",
    ]
    sid = "ECRTaggingActions"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    condition {
      test     = "ForAnyValue:ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/github-actions-oidc-br3ndonland-infrastructure-live-write"]
    }
  }
  statement {
    actions = [
      "ecr-public:BatchDeleteImage",
      "ecr-public:CompleteLayerUpload",
      "ecr-public:InitiateLayerUpload",
      "ecr-public:PutImage",
      "ecr-public:PutRegistryCatalogData",
      "ecr-public:PutRepositoryCatalogData",
      "ecr-public:UploadLayerPart",
    ]
    sid = "ECRWriteActions"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    condition {
      test     = "ForAnyValue:ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/github-actions-oidc-br3ndonland-infrastructure-live-write"]
    }
  }
}

resource "aws_ecrpublic_repository_policy" "spacelift_runner_terraform" {
  # ECR Public resources only support us-east-1.
  # https://search.opentofu.org/provider/hashicorp/aws/latest/docs/resources/ecrpublic_repository_policy
  provider = aws.us_east_1

  policy          = data.aws_iam_policy_document.spacelift_runner_terraform.json
  repository_name = aws_ecrpublic_repository.spacelift_runner_terraform.id
}
