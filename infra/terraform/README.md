# App Service Landing Zone — Terraform

This directory deploys an Azure App Service Landing Zone using the [AVM pattern module](https://registry.terraform.io/modules/Azure/avm-ptn-app-service-landing-zone/azure/latest).

## What gets deployed

| Resource | Default |
|---|---|
| App Service Plan | ✅ Linux / P1v3 |
| Web App(s) | Configurable via `web_apps` |
| Virtual Network | ✅ With App Service + private endpoint subnets |
| Private DNS Zones | ✅ `privatelink.azurewebsites.net` and others |
| Azure Front Door (Premium + WAF) | ✅ Enabled |
| Key Vault | ✅ Enabled |
| Application Insights + Log Analytics | ✅ Enabled |
| Hub VNet peering & route table | Optional — set `hub_virtual_network_id` |

> **Spoke-only deployment.** Hub networking (Azure Firewall, Bastion, hub VNet) is **not** deployed by this configuration. Deploy your hub using the [ALZ IaC Accelerator](https://aka.ms/alz/acc) and pass the hub VNet ID here for peering.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.9
- An Azure subscription
- Azure CLI authenticated (`az login`)
- (Optional) A hub VNet from the ALZ IaC Accelerator for peering

## Quick start

```bash
# 1. Copy an example variables file and edit it
cp examples/asp-linux-app.tfvars terraform.tfvars

# 2. Initialise Terraform
terraform init

# 3. Review the plan
terraform plan

# 4. Apply
terraform apply
```

## ALZ hub integration

If your hub VNet is managed by the ALZ IaC Accelerator, set these variables to peer the spoke and route traffic through your hub firewall:

```hcl
hub_virtual_network_id         = "/subscriptions/.../resourceGroups/rg-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub"
hub_firewall_private_ip        = "10.100.0.4"
hub_route_table_address_spaces = ["10.100.0.0/16"]
```

## Variables

See [`variables.tf`](variables.tf) for the full list. Key inputs:

| Variable | Required | Default | Description |
|---|---|---|---|
| `location` | Yes | — | Azure region |
| `resource_group_name` | Yes | — | Name of the resource group to create |
| `web_apps` | No | `{}` | Map of web apps to deploy |
| `app_service_plan_sku_name` | No | `P1v3` | App Service Plan SKU |
| `hub_virtual_network_id` | No | `null` | Hub VNet ID for peering |

## Outputs

See [`outputs.tf`](outputs.tf). Key outputs include web app hostnames, VNet ID, Key Vault ID, and Application Insights connection string.

## CI/CD

Deployment pipelines are provided by the OIDC bootstrap repos — not maintained in this repository:

- **GitHub Actions:** [github-terraform-oidc-ci-cd](https://github.com/Azure-Samples/github-terraform-oidc-ci-cd)
- **Azure DevOps:** [azure-devops-terraform-oidc-ci-cd](https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd)

## Further reading

- [AVM pattern module docs](https://registry.terraform.io/modules/Azure/avm-ptn-app-service-landing-zone/azure/latest)
- [App Service Landing Zone Accelerator architecture](https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/app-platform/app-services/landing-zone-accelerator)
- [Azure Landing Zones IaC Accelerator](https://aka.ms/alz/acc)
