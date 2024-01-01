output "aws_iam_roles" {
  depends_on  = [aws_iam_role.tfc_project, aws_iam_role.tfc_workspace]
  description = "ARNs and names of AWS IAM roles that have been provisioned"
  precondition {
    condition     = anytrue([length(var.tfc_projects) > 0, length(var.tfc_workspaces) > 0])
    error_message = "At least one Terraform Cloud project or workspace must be specified."
  }
  value = merge(
    {
      for key, value in local.tfc_projects :
      key => {
        arn  = aws_iam_role.tfc_project[key].arn
        name = aws_iam_role.tfc_project[key].name
      }
    },
    {
      for key, value in local.tfc_workspaces :
      key => {
        arn  = aws_iam_role.tfc_workspace[key].arn
        name = aws_iam_role.tfc_workspace[key].name
      }
    },
  )
}
