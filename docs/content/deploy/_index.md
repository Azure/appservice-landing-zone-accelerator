---
title: "Deploy"
weight: 30
geekdocCollapseSection: true
---

{{< hint type=note >}}
**ALZ hub connectivity required.** When deploying, you will need to provide your hub VNet resource ID (`hub_virtual_network_id` / `hubVnetResourceId`) and firewall private IP (`hub_firewall_private_ip` / `firewallInternalIp`). These values come from your [Platform Landing Zone](https://aka.ms/alz/acc) deployment outputs.
{{< /hint >}}

## Interactive deployment

The repo includes a PowerShell helper that guides you through configuration and deployment:

```powershell
./deploy.ps1
```

It prompts for your Azure region, IaC tool, scenario, and hub connectivity — then runs the deployment.

## Manual deployment

### Terraform

```bash
cd infra/terraform
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

**Key variables** (full reference in `infra/terraform/variables.tf`):

| Variable | Description | Default |
|----------|-------------|---------|
| `location` | Azure region | — |
| `resource_group_name` | Name of the resource group to create | — |
| `environment` | Environment label for tagging | `"prod"` |
| `app_service_plan_os_type` | OS type (`Linux`, `Windows`) | `"Linux"` |
| `app_service_plan_sku_name` | App Service Plan SKU | `"P1v3"` |
| `app_service_environment_enabled` | Use ASE v3 instead of multi-tenant | `false` |
| `container_registry_enabled` | Deploy Azure Container Registry | `false` |
| `front_door_enabled` | Deploy Azure Front Door | `true` |
| `hub_virtual_network_id` | Hub VNet resource ID for peering | `null` |
| `hub_firewall_private_ip` | Hub firewall IP for UDR | `null` |

**State backend** — `infra/terraform/terraform.tf` has an empty `backend "azurerm" {}` block. Do not hardcode values in it. Instead, pass backend config via CLI args:

```bash
terraform init \
  -backend-config="resource_group_name=<state-rg>" \
  -backend-config="storage_account_name=<state-sa>" \
  -backend-config="container_name=dev" \
  -backend-config="key=appservice-lza.tfstate" \
  -backend-config="use_oidc=true"
```

If you used the [CI/CD Bootstrap]({{< relref "bootstrap" >}}), the pipeline injects these values automatically — no manual configuration needed. For local development without remote state, run `terraform init -backend=false`.

### Bicep

```bash
cd infra/bicep
az deployment sub create \
  --location <region> \
  --template-file main.bicep \
  --parameters main.bicepparam
```

**Key parameters** (full reference in `infra/bicep/main.bicep`):

| Parameter | Description | Default |
|-----------|-------------|---------|
| `workloadName` | Name prefix (up to 10 chars) | — |
| `location` | Azure region | deployment location |
| `environmentName` | Environment label | `"dev"` |
| `logAnalyticsWorkspaceResourceId` | Log Analytics workspace resource ID | — |
| `deployAseV3` | Use ASE v3 instead of multi-tenant | `false` |
| `appServicePlanSku` | App Service Plan SKU | `"P1V3"` |
| `appServicePlanOs` | OS (`windows`, `linux`) | `"windows"` |
| `hubVnetResourceId` | Hub VNet resource ID for peering | `""` |
| `firewallInternalIp` | Firewall IP for UDR | `""` |

Bicep uses [Deployment Stacks](https://learn.microsoft.com/azure/azure-resource-manager/bicep/deployment-stacks) at subscription level for lifecycle management and drift detection.

## Via CI/CD pipeline

If you bootstrapped CI/CD (see [Bootstrap]({{< relref "bootstrap" >}})):

1. Push changes to a feature branch
2. Open a PR — the pipeline runs `terraform plan` / `bicep build` and posts the result
3. Merge to `main` — deploys to dev, then promotes through test → prod with approval gates
