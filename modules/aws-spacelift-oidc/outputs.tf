output "aws_iam_roles" {
  description = "ARNs and names of AWS IAM roles that have been provisioned by this module"
  value = {
    for key, value in aws_iam_role.spacelift_oidc :
    key => {
      arn  = value.arn
      name = value.name
    }
  }
}
