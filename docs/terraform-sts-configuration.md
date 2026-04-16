# Terraform STS configuration (GetCallerIdentity)

Complete pattern so STS-backed identity works with Terraform: provider, variable, data source, optional `check`, optional output, AWS IAM requirements, and Terraform Cloud notes.

## 1. Terraform code (root module, e.g. under `tests/`)

### `variables.tf` (or in `sts.tf`)

```hcl
variable "expected_aws_account_id" {
  description = "12-digit AWS account ID this workspace must use."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_aws_account_id))
    error_message = "expected_aws_account_id must be a 12-digit account id."
  }
}
```

### `providers.tf` (or in `sts.tf`)

Adjust `assume_role` only if you assume into the target account from a hub.

```hcl
terraform {
  required_version = ">= 1.5" # needed for check {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region # or a literal "us-east-1"

  # Optional: only if TFC runs in Account A and resources/identity must be Account B
  # assume_role {
  #   role_arn     = var.target_role_arn
  #   external_id  = var.external_id # if your org uses it
  #   session_name = "tfc-${terraform.workspace}"
  # }
}
```

You need a `variable "aws_region"` (or hardcode region). The provider must resolve to credentials that can call STS in the account you care about **before** any apply-only values are required.

### `sts.tf`

```hcl
data "aws_caller_identity" "current" {}

check "aws_caller_account" {
  assert {
    condition     = data.aws_caller_identity.current.account_id == var.expected_aws_account_id
    error_message = "AWS caller account_id is ${data.aws_caller_identity.current.account_id}, expected ${var.expected_aws_account_id}."
  }
}

output "terraform_aws_caller_identity" {
  value = {
    account_id = data.aws_caller_identity.current.account_id
    arn        = data.aws_caller_identity.current.arn
    user_id    = data.aws_caller_identity.current.user_id
  }
}
```

### `terraform.tfvars` (same root as this config, e.g. `tests/terraform.tfvars`)

```hcl
expected_aws_account_id = "123456789012"
aws_region              = "us-east-1"
```

## 2. AWS IAM: what must be allowed

Whatever principal Terraform uses (IAM user/role from env, or the role TFC assumes) needs at least:

- **`sts:GetCallerIdentity`** — required for `aws_caller_identity` (and for the provider to validate credentials).

If you use **`provider` `assume_role`**, the **starting** credentials must be allowed to **`sts:AssumeRole`** on the target role, and the **target role’s trust policy** must trust that principal (TFC’s OIDC role, your CI role, etc.).

## 3. Terraform Cloud

- **Working directory** must be the folder that contains these files (e.g. `tests/`).
- Set **`expected_aws_account_id`** (and region / role ARNs) via **`tests/terraform.tfvars`** and/or **workspace variables** / **variable sets** — same effect as long as variables are set for the run.
- If you use **dynamic credentials** with the AWS provider in TFC, configure the workspace’s **AWS auth** so the run receives credentials for the **same** account as `expected_aws_account_id` (or the hub role that then assumes into that account via `assume_role`).

## 4. Common reasons it still fails

- **`assume_role` depends on a resource** created in the same apply → caller identity (and your `check`) can be unknown or wrong at plan time. Prefer **fixed** role ARNs from variables.
- **Wrong account in `expected_aws_account_id`** vs actual caller → `check` fails (by design).
- **Missing `sts:GetCallerIdentity`** on the effective principal → data source error.

## 5. Related: workspace layout

If Terraform Cloud **working directory** is `tests/`, place `sts.tf` and `terraform.tfvars` under **`tests/`** so they are loaded. A `terraform.tfvars` at repo root is **not** read for a run rooted in `tests/`.

---

*Generated for License Monitoring Console / Splunk SecOps automation docs.*
