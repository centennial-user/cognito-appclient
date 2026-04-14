# Cognito App Client Project Guide

## Project purpose

This project uses Terraform to manage an AWS Cognito app client for `helloapp` with Hosted UI OAuth settings.

The main goals are:

- Keep Cognito app client configuration version-controlled.
- Use a modular Terraform design so the module can be reused for other app clients.
- Make callback URLs, scopes, and token behavior explicit and auditable.

## What this Terraform project manages

### Core resource

- `aws_cognito_user_pool_client` for:
  - App client name: `helloapp`
  - Hosted UI callback URLs
  - Allowed OAuth flows and scopes
  - Identity provider and explicit auth flows
  - Token validity and related security options

### Optional resource

- `aws_cognito_user_pool_domain` (only when `create_domain = true`)
  - Domain prefix default: `abc-prod`
  - Full hosted UI URL example: `https://abc-prod.auth.us-east-1.amazoncognito.com`

## Project structure

- `main.tf`  
  Calls the reusable module and passes all inputs.

- `variables.tf`  
  Defines root-level variables and defaults from `notes.txt`.

- `outputs.tf`  
  Exposes key outputs like app client ID/name and managed domain.

- `provider.tf` and `versions.tf`  
  AWS provider and Terraform version constraints.

- `modules/cognito_app_client/`  
  Reusable module containing:
  - `main.tf` (resource definitions)
  - `variables.tf` (module inputs)
  - `outputs.tf` (module outputs)

- `terraform.tfvars.example`  
  Example environment values to copy into `terraform.tfvars`.

- `docs/workflow-diagram.drawio`  
  Editable draw.io diagram with AWS-style icons and flow numbers.

- `docs/workflow-diagram.md`  
  Mermaid version of the workflow.

## Configuration highlights

### Callback URLs

- `http://localhost:4200/login`
- `http://localhost:4200/silent-renew.html`
- `https://intranet.int.abcd.fghi.uvwx.gov/HELLOAPP.Frontend/dev/helloapp-frontend/`

### OAuth scopes

- `uvwx_credential_data/uvwx_credential_data`
- `aws.cognito.signin.user.admin`
- `email`
- `openid`
- `phone`
- `profile`

## Workflow (numbered process flow)

This section maps directly to the numbering in `docs/workflow-diagram.drawio`.

1. **Run Terraform apply flow**  
   Start with Terraform from root configuration.

2. **Module creates/updates Cognito settings**  
   Root module sends configuration into `modules/cognito_app_client`.

3. **App client is created in user pool**  
   Cognito app client is created/updated in the target user pool.

4. **Hosted UI endpoint is configured**  
   App client OAuth settings are tied to hosted UI behavior.

5. **Scope configuration is applied**  
   Allowed OAuth scopes are set on the app client.

6. **Frontend redirects user to Hosted UI**  
   App sends users to Cognito hosted UI for authentication.

7. **Tokens return to callback URL**  
   Cognito redirects back to configured callback URLs with auth result.

## How to run

1. Copy `terraform.tfvars.example` to `terraform.tfvars`.
2. Set `user_pool_id` to your target Cognito user pool.
3. Run:
   - `terraform init`
   - `terraform validate`
   - `terraform plan`
   - `terraform apply`

## Preconditions and notes

- Custom scope `uvwx_credential_data/uvwx_credential_data` must already exist in the user pool resource server unless managed separately.
- Keep `create_domain = false` if the domain is already created and managed outside this Terraform stack.
- Use `create_domain = true` only when Terraform should own/manage the user pool domain prefix.

## Expected outputs

After apply, Terraform returns:

- `app_client_id`
- `app_client_name`
- `managed_domain` (null when `create_domain = false`)
