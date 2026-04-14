output "app_client_id" {
  description = "Cognito app client ID."
  value       = module.helloapp_cognito_client.app_client_id
}

output "app_client_name" {
  description = "Cognito app client name."
  value       = module.helloapp_cognito_client.app_client_name
}

output "managed_domain" {
  description = "Managed Cognito domain value when create_domain is true; otherwise null."
  value       = module.helloapp_cognito_client.managed_domain
}
