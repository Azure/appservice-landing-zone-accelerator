---
title: "Azure DevOps"
weight: 20
---

> **Source:** [`Azure-Samples/azure-devops-terraform-oidc-ci-cd`](https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd)

## Prerequisites

- [Terraform CLI](https://www.terraform.io/downloads) and [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- [Azure subscription](https://azure.microsoft.com/pricing/purchase-options/azure-account) with Owner role
- [Azure DevOps Organization and Project](https://aex.dev.azure.com/signup/) (free tier with at least one pipeline)
- An Azure DevOps PAT ([PAT instructions](https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd#generate-a-pat-personal-access-token-in-azure-devops))

## Steps

### 1. Clone and configure

```bash
git clone https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd.git
cd azure-devops-terraform-oidc-ci-cd/bootstrap
```

Create `terraform.tfvars`:

```hcl
location          = "uksouth"
organization_name = "my-azdo-org"

approvers = {
  user1 = "approver@example.com"
}
```

### 2. Apply

```bash
az login -T "<tenant_id>"
az account set --subscription "<subscription_id>"

export TF_VAR_personal_access_token="<your_azdo_pat>"    # Linux/macOS
# $env:TF_VAR_personal_access_token = "<your_azdo_pat>"  # PowerShell

terraform init
terraform plan -out tfplan
terraform apply tfplan
```

### 3. Connect to this repo's infrastructure

Set the `example_repo` input to point at `infra/terraform/` in this repo (or your fork). The bootstrap creates a new repo with CI/CD pipelines that run `terraform plan`/`apply` against that path.

**No changes to `terraform.tf` are needed.** The empty `backend "azurerm" {}` block in `infra/terraform/terraform.tf` is intentional — the generated pipeline injects backend config at runtime via `-backend-config` CLI args (storage account, container, key). See the [example-module](https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd/tree/main/example-module) in the bootstrap repo for the reference pattern.

#### Local development

To run Terraform locally against the bootstrap's state storage, pass the backend config from the bootstrap outputs:

```bash
cd infra/terraform
terraform init \
  -backend-config="resource_group_name=<bootstrap-state-rg>" \
  -backend-config="storage_account_name=<bootstrap-state-sa>" \
  -backend-config="container_name=dev" \
  -backend-config="key=appservice-lza.tfstate" \
  -backend-config="use_oidc=true"
```

Or use local state for experimentation (no backend config required — comment out the `backend` block or run `terraform init -backend=false`).

## Clean up

```bash
cd azure-devops-terraform-oidc-ci-cd/bootstrap
terraform destroy
```

> Destroy may fail on the first attempt due to dependency ordering. Run again if needed.
