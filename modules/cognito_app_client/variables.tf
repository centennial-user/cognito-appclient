variable "user_pool_id" {
  description = "Cognito User Pool ID."
  type        = string
}

variable "app_client_name" {
  description = "Cognito app client name."
  type        = string
}

variable "generate_secret" {
  description = "Whether to generate a client secret."
  type        = bool
}

variable "callback_urls" {
  description = "Allowed callback URLs."
  type        = list(string)
}

variable "logout_urls" {
  description = "Allowed logout URLs."
  type        = list(string)
}

variable "allowed_oauth_scopes" {
  description = "Allowed OAuth scopes."
  type        = list(string)
}

variable "allowed_oauth_flows" {
  description = "Allowed OAuth flows."
  type        = list(string)
}

variable "allowed_oauth_flows_user_pool_client" {
  description = "Enable OAuth on app client."
  type        = bool
}

variable "supported_identity_providers" {
  description = "Supported identity providers."
  type        = list(string)
}

variable "explicit_auth_flows" {
  description = "Explicit auth flows."
  type        = list(string)
}

variable "access_token_validity" {
  description = "Access token validity duration."
  type        = number
}

variable "id_token_validity" {
  description = "ID token validity duration."
  type        = number
}

variable "refresh_token_validity" {
  description = "Refresh token validity duration."
  type        = number
}

variable "token_validity_units" {
  description = "Token validity units."
  type = object({
    access_token  = string
    id_token      = string
    refresh_token = string
  })
}

variable "prevent_user_existence_errors" {
  description = "Behavior for user existence errors."
  type        = string
}

variable "enable_token_revocation" {
  description = "Enable token revocation."
  type        = bool
}

variable "enable_propagate_additional_user_context_data" {
  description = "Enable additional user context propagation."
  type        = bool
}

variable "create_domain" {
  description = "Whether to create the Cognito domain."
  type        = bool
}

variable "domain_prefix" {
  description = "Cognito domain prefix."
  type        = string
}
