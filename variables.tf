variable "aws_region" {
  description = "AWS region for Cognito resources."
  type        = string
  default     = "us-east-1"
}

variable "user_pool_id" {
  description = "Existing Cognito User Pool ID where the app client will be created."
  type        = string
}

variable "app_client_name" {
  description = "Cognito app client name."
  type        = string
  default     = "helloapp"
}

variable "generate_secret" {
  description = "Whether the app client should generate a client secret."
  type        = bool
  default     = false
}

variable "callback_urls" {
  description = "Allowed callback URLs."
  type        = list(string)
  default = [
    "http://localhost:4200/login",
    "http://localhost:4200/silent-renew.html",
    "https://intranet.int.abcd.fghi.uvwx.gov/HELLOAPP.Frontend/dev/helloapp-frontend/"
  ]
}

variable "logout_urls" {
  description = "Allowed logout URLs."
  type        = list(string)
  default     = []
}

variable "allowed_oauth_scopes" {
  description = "Allowed OAuth scopes for Hosted UI."
  type        = list(string)
  default = [
    "uvwx_credential_data/uvwx_credential_data",
    "aws.cognito.signin.user.admin",
    "email",
    "openid",
    "phone",
    "profile"
  ]
}

variable "allowed_oauth_flows" {
  description = "OAuth flows enabled for the app client."
  type        = list(string)
  default     = ["code", "implicit"]
}

variable "allowed_oauth_flows_user_pool_client" {
  description = "Enables OAuth 2.0 authorization server features for this app client."
  type        = bool
  default     = true
}

variable "supported_identity_providers" {
  description = "Identity providers supported by this app client."
  type        = list(string)
  default     = ["COGNITO"]
}

variable "explicit_auth_flows" {
  description = "Authentication flows enabled for this app client."
  type        = list(string)
  default = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

variable "access_token_validity" {
  description = "Access token validity duration."
  type        = number
  default     = 60
}

variable "id_token_validity" {
  description = "ID token validity duration."
  type        = number
  default     = 60
}

variable "refresh_token_validity" {
  description = "Refresh token validity duration."
  type        = number
  default     = 30
}

variable "token_validity_units" {
  description = "Token validity units for access, ID, and refresh tokens."
  type = object({
    access_token  = string
    id_token      = string
    refresh_token = string
  })
  default = {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

variable "prevent_user_existence_errors" {
  description = "Behavior for user existence errors."
  type        = string
  default     = "ENABLED"
}

variable "enable_token_revocation" {
  description = "Enables token revocation."
  type        = bool
  default     = true
}

variable "enable_propagate_additional_user_context_data" {
  description = "Enables propagation of additional user context data."
  type        = bool
  default     = false
}

variable "create_domain" {
  description = "Whether to create/manage a Cognito User Pool domain in Terraform."
  type        = bool
  default     = false
}

variable "domain_prefix" {
  description = "Cognito User Pool domain prefix (for example: abc-prod). Used only when create_domain is true."
  type        = string
  default     = "abc-prod"
}
