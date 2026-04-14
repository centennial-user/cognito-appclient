module "helloapp_cognito_client" {
  source = "./modules/cognito_app_client"

  user_pool_id                                  = var.user_pool_id
  app_client_name                               = var.app_client_name
  generate_secret                               = var.generate_secret
  callback_urls                                 = var.callback_urls
  logout_urls                                   = var.logout_urls
  allowed_oauth_scopes                          = var.allowed_oauth_scopes
  allowed_oauth_flows                           = var.allowed_oauth_flows
  allowed_oauth_flows_user_pool_client          = var.allowed_oauth_flows_user_pool_client
  supported_identity_providers                  = var.supported_identity_providers
  explicit_auth_flows                           = var.explicit_auth_flows
  access_token_validity                         = var.access_token_validity
  id_token_validity                             = var.id_token_validity
  refresh_token_validity                        = var.refresh_token_validity
  token_validity_units                          = var.token_validity_units
  prevent_user_existence_errors                 = var.prevent_user_existence_errors
  enable_token_revocation                       = var.enable_token_revocation
  enable_propagate_additional_user_context_data = var.enable_propagate_additional_user_context_data

  create_domain = var.create_domain
  domain_prefix = var.domain_prefix
}
