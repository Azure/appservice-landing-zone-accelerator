---
title: "Examples"
weight: 50
geekdocCollapseSection: true
---

{{< hint type=important >}}
**All examples assume deployment into an Azure Platform Landing Zone** with hub networking and Azure Firewall already provisioned. See [ALZ Integration]({{< relref "alz-integration" >}}) for details.
{{< /hint >}}

All scenarios use the same codebase — toggle feature flags in your variable/parameter file. No code changes needed.

## Scenarios

| # | Scenario | Terraform example | Bicep example |
|---|----------|-------------------|---------------|
| 1 | **ASE v3 — Windows App** | `ase-windows-app.tfvars` | `ase-windows-app.bicepparam` |
| 2 | **ASE v3 — Windows Container** | `ase-windows-container.tfvars` | `ase-windows-container.bicepparam` |
| 3 | **ASE v3 — Linux App** | `ase-linux-app.tfvars` | `ase-linux-app.bicepparam` |
| 4 | **ASE v3 — Linux Container** | `ase-linux-container.tfvars` | `ase-linux-container.bicepparam` |
| 5 | **App Service Plan — Windows App** | `asp-windows-app.tfvars` | `asp-windows-app.bicepparam` |
| 6 | **App Service Plan — Windows Container** | `asp-windows-container.tfvars` | `asp-windows-container.bicepparam` |
| 7 | **App Service Plan — Linux App** | `asp-linux-app.tfvars` | `asp-linux-app.bicepparam` |
| 8 | **App Service Plan — Linux Container** | `asp-linux-container.tfvars` | `asp-linux-container.bicepparam` |
| 9 | **Managed Instance** | `managed-instance.tfvars` | `managed-instance.bicepparam` |

All examples are in `infra/terraform/examples/` and `infra/bicep/examples/`. Each includes ALZ hub integration parameters (VNet peering, firewall egress lockdown). See the README in each examples directory for usage instructions.

## Feature flags

**Terraform** (`terraform.tfvars`):

```hcl
app_service_environment_enabled = true   # ASE v3
container_registry_enabled      = true   # Container support
front_door_enabled              = true   # Azure Front Door
key_vault_enabled               = true   # Key Vault
application_insights_enabled    = true   # App Insights + Log Analytics
```

**Bicep** (`.bicepparam`):

```bicep
param deployAseV3 = true
param appServicePlanOs = 'linux'
param appServiceKind = 'app,linux,container'
param containerImageName = 'mcr.microsoft.com/appsvc/staticsite:latest'
```

## Sample application

A sample ASP.NET Core app is in [`sampleapp/`](https://github.com/Azure/appservice-landing-zone-accelerator/tree/main/sampleapp) for testing.
