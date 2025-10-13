output "aws_integrations_with_oidc" {
  description = "Spacelift AWS integrations provisioned with OIDC"
  value       = { for integration in spacelift_aws_integration.oidc : integration.name => integration }
}
