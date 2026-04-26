# AWS Cognito AppClient Setup For BETA

The parent company `ALPHA` should own or expose the shared Cognito User Pool at the root level. The `BETA` company module should receive ALPHA's `user_pool_id` and create only its own Cognito App Client.

Unless `BETA` needs complete authentication isolation, the `BETA` module should not create a separate Cognito User Pool.

## Root / ALPHA Module

```hcl
module "beta_company" {
  source = "./modules/company"

  company_name = "BETA"

  cognito_user_pool_id = module.alpha_cognito.user_pool_id

  callback_urls = [
    "https://beta.example.com/callback"
  ]

  logout_urls = [
    "https://beta.example.com/logout"
  ]

  allowed_oauth_scopes = [
    "openid",
    "email",
    "profile"
  ]
}
```

## BETA / Company Module

```hcl
variable "company_name" {
  type = string
}

variable "cognito_user_pool_id" {
  type = string
}

variable "callback_urls" {
  type = list(string)
}

variable "logout_urls" {
  type = list(string)
}

variable "allowed_oauth_scopes" {
  type    = list(string)
  default = ["openid", "email", "profile"]
}

resource "aws_cognito_user_pool_client" "app_client" {
  name         = "${var.company_name}-app-client"
  user_pool_id = var.cognito_user_pool_id

  generate_secret = false

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = [
    "code"
  ]

  allowed_oauth_scopes = var.allowed_oauth_scopes

  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  supported_identity_providers = [
    "COGNITO"
  ]

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"

  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

output "app_client_id" {
  value = aws_cognito_user_pool_client.app_client.id
}
```

## Key Configuration Rule

```hcl
BETA AppClient -> uses ALPHA/root Cognito User Pool ID
```

Avoid this unless BETA requires complete authentication isolation:

```hcl
BETA module -> creates separate user pool
```

## Modeling Company Hierarchy

If `BETA belongs under ALPHA` is a tenant or company hierarchy concept, Cognito App Clients do not model that hierarchy by themselves.

Use one or more of the following:

- a custom user attribute such as `custom:company_id = BETA`
- one app client per company
- Cognito groups such as `ALPHA_ADMIN` or `BETA_USER`
- a pre-token-generation Lambda that injects `company_id` and `parent_company_id` claims into tokens
