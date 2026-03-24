# App Service Landing Zone Accelerator — Bicep

This directory contains the Bicep deployment for the App Service Landing Zone Accelerator using the [AVM pattern module](https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/app-service-lza/hosting-environment) (`br/public:avm/ptn/app-service-lza/hosting-environment:0.2.0`).

A single module call deploys the complete spoke workload: VNet, subnets, NSGs, App Service Plan, Web App, Key Vault, Application Insights, Azure Front Door with WAF, private endpoints, private DNS zones, and managed identities.

> **Spoke-only model** — This repo does **not** deploy hub networking (Azure Firewall, Bastion, hub VNet). Provision your hub using the [ALZ IaC Accelerator](https://aka.ms/alz/acc) and connect it via the optional hub peering parameters.

## Prerequisites

| Requirement | Details |
|---|---|
| **Azure CLI** | v2.61+ with Bicep CLI v0.30+ (`az bicep version`) |
| **Subscription** | Contributor + User Access Administrator on the target subscription |
| **Log Analytics workspace** | A workspace resource ID — typically created by the platform team or ALZ |
| **Hub VNet (optional)** | Resource ID of the hub VNet if you want spoke-to-hub peering |

## Quick Start

### 1. Configure parameters

Copy `main.bicepparam` and update the values:

```bash
cp main.bicepparam my-env.bicepparam
```

At minimum set:

- `workloadName` — short name for resource naming (max 10 characters)
- `location` — Azure region (e.g. `eastus2`)
- `logAnalyticsWorkspaceResourceId` — full resource ID of your Log Analytics workspace
- `resourceGroupName` — name for the spoke resource group (the module creates it for you)

### 2. Deploy

**Option A — Standard subscription deployment:**

```bash
az deployment sub create \
  --location eastus2 \
  --template-file main.bicep \
  --parameters my-env.bicepparam
```

**Option B — Deployment Stack (recommended for lifecycle management):**

```bash
az stack sub create \
  --name app-service-lza \
  --location eastus2 \
  --template-file main.bicep \
  --parameters my-env.bicepparam \
  --action-on-unmanage detachAll \
  --deny-settings-mode none
```

Deployment Stacks track all resources created by the template and clean up removed resources automatically on redeployment.

### 3. Verify

```bash
# Check deployed resources
az deployment sub show --name <deployment-name> --query properties.outputs

# Or list the stack resources
az stack sub show --name app-service-lza --query resources
```

## Connecting to an Existing Hub VNet (ALZ IaC Accelerator)

If you have deployed a hub using the [ALZ IaC Accelerator](https://aka.ms/alz/acc), set these parameters in your `.bicepparam` file:

```bicep
// Hub VNet resource ID from the ALZ IaC Accelerator output
param hubVnetResourceId = '/subscriptions/<hub-sub>/resourceGroups/<hub-rg>/providers/Microsoft.Network/virtualNetworks/<hub-vnet>'

// Internal IP of the Azure Firewall (enables egress lockdown via UDR)
param firewallInternalIp = '10.0.0.4'
```

When `hubVnetResourceId` is provided:

- A VNet peering is created between the spoke and hub
- When `firewallInternalIp` is also set, a route table with a default route to the firewall is applied (egress lockdown)

When these parameters are omitted the spoke deploys standalone with no peering.

## What Gets Deployed

| Resource | Description |
|---|---|
| Resource Group | Spoke resource group (created by the AVM resource group module) |
| Virtual Network | Spoke VNet with App Service and private endpoint subnets |
| NSGs | Network security groups for each subnet |
| Route Table | UDR for egress lockdown (only when firewall IP is set) |
| App Service Plan | Configurable SKU, OS, zone redundancy |
| Web App | HTTPS-only, TLS 1.2+, basic auth disabled, health checks |
| Key Vault | RBAC-authorized, purge-protected, private-endpoint-only |
| Application Insights | Private ingestion, Entra-only auth, 90-day retention |
| Front Door + WAF | Premium tier with default unsafe-method blocking rule |
| Private Endpoints | For Web App, Key Vault |
| Private DNS Zones | For private endpoint resolution |
| Managed Identity | User-assigned identity for the Web App |

## CI/CD

This repo does not include deployment workflows. Use the OIDC bootstrap repos to set up CI/CD:

- **GitHub Actions:** [github-terraform-oidc-ci-cd](https://github.com/Azure-Samples/github-terraform-oidc-ci-cd)
- **Azure DevOps:** [azure-devops-terraform-oidc-ci-cd](https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd)

## Customisation

The AVM pattern module exposes many optional configuration objects. See the [module documentation](https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/app-service-lza/hosting-environment) for the full parameter reference. The most common customisations:

- **ASE v3** — Set `deployAseV3: true` and provide `aseConfig` in `main.bicep`
- **Application Gateway** — Change `ingressOption` to `'applicationGateway'` and set `appGwSubnetAddressSpace` + `appGatewayConfig`
- **Linux containers** — Set `appServicePlanOs` to `'linux'` and configure `appServiceConfig.container`
- **Existing App Service Plan** — Provide `servicePlanConfig.existingPlanId` to skip plan creation
