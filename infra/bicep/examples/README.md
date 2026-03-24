# App Service Landing Zone Accelerator — Deployment Examples

This folder contains 9 ready-to-deploy `.bicepparam` files covering every supported hosting model. Each example is configured for **ALZ Platform Landing Zone integration** with hub VNet peering, firewall egress lockdown, private DNS zones, and diagnostic settings.

## Prerequisites

1. An Azure subscription with Contributor + User Access Administrator roles
2. A **Log Analytics workspace** provisioned by the platform team (or via the [ALZ IaC Accelerator](https://aka.ms/alz/acc))
3. A **hub VNet** with Azure Firewall deployed (typically from the ALZ IaC Accelerator)
4. Azure CLI 2.61+ with the Bicep CLI

## Quick Start

```bash
# 1. Replace placeholders in your chosen .bicepparam file:
#    - <subscription-id>, <hub-subscription-id>
#    - <rg-name>, <workspace-name>
#    - Container registry URLs (for container scenarios)

# 2. Deploy
az deployment sub create \
  --location eastus2 \
  --template-file ../main.bicep \
  --parameters <example>.bicepparam

# Or use Deployment Stacks for lifecycle management:
az stack sub create \
  --name appsvc-lza \
  --location eastus2 \
  --template-file ../main.bicep \
  --parameters <example>.bicepparam \
  --deny-settings-mode denyWriteAndDelete \
  --action-on-unmanage deleteAll
```

## Examples

| # | File | Hosting Model | OS | App Type | SKU |
|---|------|---------------|----|----------|-----|
| 1 | [`managed-instance.bicepparam`](managed-instance.bicepparam) | Windows Managed Instance | Windows | Code (custom mode) | P1V3 |
| 2 | [`ase-windows-app.bicepparam`](ase-windows-app.bicepparam) | ASE v3 | Windows | Code | I1v2 |
| 3 | [`ase-windows-container.bicepparam`](ase-windows-container.bicepparam) | ASE v3 | Windows | Container | I1v2 |
| 4 | [`ase-linux-app.bicepparam`](ase-linux-app.bicepparam) | ASE v3 | Linux | Code | I1v2 |
| 5 | [`ase-linux-container.bicepparam`](ase-linux-container.bicepparam) | ASE v3 | Linux | Container | I1v2 |
| 6 | [`asp-windows-app.bicepparam`](asp-windows-app.bicepparam) | App Service Plan | Windows | Code | P1V3 |
| 7 | [`asp-windows-container.bicepparam`](asp-windows-container.bicepparam) | App Service Plan | Windows | Container | P1V3 |
| 8 | [`asp-linux-app.bicepparam`](asp-linux-app.bicepparam) | App Service Plan | Linux | Code | P1V3 |
| 9 | [`asp-linux-container.bicepparam`](asp-linux-container.bicepparam) | App Service Plan | Linux | Container | P1V3 |

## Scenario Details

### Managed Instance (`managed-instance.bicepparam`)

Deploys a **Windows Managed Instance** — a custom-mode App Service Plan that provides a dedicated Windows VM with RDP access and customer-provided storage. Use this when you need full control over the hosting environment without the overhead of ASE v3.

- Custom mode enabled (`appServicePlanCustomMode = true`)
- Storage account required (`storageAccountRequired = true`)
- Premium V3 SKU for production workloads

### ASE v3 Scenarios (`ase-*.bicepparam`)

Deploy into a fully **isolated App Service Environment v3**. ASE provides single-tenant infrastructure with a dedicated subnet (requires /24). Choose between Windows/Linux and code/container hosting.

- Isolated V2 SKU (`I1v2`) — dedicated compute in the ASE
- ASE subnet sized at /24 (required by ASE v3)
- Zone-redundant by default
- Internal load balancing for private access

### Multitenant App Service Plan Scenarios (`asp-*.bicepparam`)

Deploy into a **shared multitenant App Service Plan** — the most cost-effective option for production workloads that don't require network isolation at the infrastructure level.

- Premium V3 SKU (`P1V3`) — production-ready with VNet integration
- Standard /26 subnet for App Service integration
- Zone-redundant by default
- Private endpoints for secure access

## ALZ Integration

Every example includes these ALZ Platform Landing Zone settings:

| Setting | Value |
|---------|-------|
| Hub VNet peering | Enabled (placeholder resource ID) |
| Firewall egress | Locked down via `10.0.0.4` route |
| Private DNS zones | Auto-created and linked to spoke VNet |
| Diagnostics | Sent to central Log Analytics workspace |
| Tags | `environment`, `workload`, `deployed_by`, `cost_center` |
| Key Vault | RBAC mode, purge protected, private-only |
| App Insights | Private ingestion, Entra-only auth |
| Front Door | Premium SKU with WAF method blocking |
| TLS | Minimum 1.2, FTPS disabled |

## Container Scenarios

Container examples (`*-container.bicepparam`) include:

- `containerImageName` — full image reference (e.g. `myregistry.azurecr.io/myapp/api:v2.1`)
- `containerRegistryUrl` — ACR endpoint URL (e.g. `https://myregistry.azurecr.io`)

The pattern module configures the web app with `DOCKER|<imageName>` in the appropriate framework version setting (`linuxFxVersion` or `windowsFxVersion`). The managed identity created by the module can be granted ACR pull access for passwordless image pulls.

## Network Address Spaces

Each example uses a unique spoke VNet CIDR to avoid conflicts when deploying multiple scenarios into the same hub:

| Scenario | Spoke VNet CIDR |
|----------|-----------------|
| Managed Instance | `10.241.0.0/20` |
| ASE Windows App | `10.242.0.0/20` |
| ASE Windows Container | `10.243.0.0/20` |
| ASE Linux App | `10.244.0.0/20` |
| ASE Linux Container | `10.245.0.0/20` |
| ASP Windows App | `10.246.0.0/20` |
| ASP Windows Container | `10.247.0.0/20` |
| ASP Linux App | `10.248.0.0/20` |
| ASP Linux Container | `10.249.0.0/20` |
