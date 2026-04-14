output "app_client_id" {
  description = "Cognito app client ID."
  value       = aws_cognito_user_pool_client.this.id
}

output "app_client_name" {
  description = "Cognito app client name."
  value       = aws_cognito_user_pool_client.this.name
}

output "managed_domain" {
  description = "Managed Cognito domain if created."
  value       = var.create_domain ? aws_cognito_user_pool_domain.this[0].domain : null
}
