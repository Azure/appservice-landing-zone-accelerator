# Product Requirements Document: AVM Migration & CI/CD Bootstrapping

## Executive Summary

### What We're Doing

Refactoring the App Service Landing Zone Accelerator repository to:

1. **Adopt AVM Pattern Modules** — Leverage the AVM **pattern modules** for App Service Landing Zone (`avm-ptn-app-service-landing-zone` for Terraform, `avm/ptn/app-service-lza/hosting-environment` for Bicep), which package the entire landing zone as a single, production-ready AVM module. These pattern modules essentially ARE the App Service Landing Zone Accelerator delivered as AVM modules, dramatically simplifying our codebase.
2. **Spoke-Only Focus** — This repo deploys the **App Service workload spoke** into an existing landing zone. Hub networking (VNet hub, Azure Firewall, Bastion, hub-spoke peering) is **out of scope** — users should provision their hub using the [ALZ IaC Accelerator](https://aka.ms/alz/acc) and connect it via the pattern module's input parameters for hub peering and centralized routing.
3. **Supplement with AVM Resource Modules** — Where the pattern module doesn't cover specific features, use individual AVM resource modules to fill gaps
4. **Flatten Repository Structure** — Remove the `scenarios/secure-baseline-multitenant/` nesting; move to a simple `infra/terraform/` and `infra/bicep/` layout at the repo root
5. **Add CI/CD Bootstrapping** — Integrate OIDC-based CI/CD bootstrap solutions for both GitHub Actions and Azure DevOps, based on proven reference implementations
6. **Maintain Solution Value** — Preserve the Landing Zone Accelerator's architectural guidance, secure baseline patterns, and sample application while improving maintainability and alignment with Microsoft best practices

### Why We're Doing It

**Business Drivers:**
- **Reduce maintenance burden** — Shift module maintenance to Microsoft's AVM team
- **Improve reliability** — Leverage Microsoft-tested, Well-Architected Framework-aligned modules
- **Accelerate adoption** — Provide turnkey CI/CD bootstrap to reduce time-to-production
- **Stay current** — Align with Microsoft's strategic direction for IaC standardization

**Technical Drivers:**
- Custom modules duplicate work that AVM already provides
- AVM **pattern modules** now exist that deploy the entire App Service Landing Zone in a single module call — replacing dozens of custom modules at once
- OIDC authentication is the modern, secure standard (vs. service principals with secrets)
- AVM modules receive continuous updates for new Azure features
- Consistent module interface patterns improve developer experience

### Success Metrics

- ✅ Pattern modules validated against all scenarios (secure-baseline-multitenant, ASE v3)
- ✅ Custom modules replaced by pattern module (or individual AVM resource modules where gaps exist)
- ✅ Zero functionality regression — all scenarios deploy successfully
- ✅ CI/CD bootstrap modules integrated and documented
- ✅ Documentation updated to reflect pattern module usage
- ✅ Legacy deployment workflows and composite actions removed from `.github/`
- ✅ CI/CD handled entirely by OIDC bootstrap repos (no custom deployment workflows in this repo)
- ✅ State migration path documented for existing deployments

---

## Current State

### Repository Structure

```
appservice-landing-zone-accelerator/
├── scenarios/
│   ├── secure-baseline-multitenant/
│   │   ├── terraform/           # Hub/spoke orchestration
│   │   │   ├── hub/             # Hub network with Firewall, Bastion  ⚠️ OUT OF SCOPE — see ALZ IaC Accelerator (aka.ms/alz/acc)
│   │   │   ├── spoke/           # Spoke network with App Service, SQL, Redis, OpenAI
│   │   │   ├── main.tf          # Entry point, provider config
│   │   │   └── backend.hcl.template
│   │   └── bicep/               # Bicep orchestration
│   │       ├── main.bicep       # Subscription-level deployment
│   │       ├── deploy.hub.bicep # ⚠️ OUT OF SCOPE — hub resources move to ALZ IaC Accelerator
│   │       ├── deploy.spoke.bicep
│   │       └── modules/         # Scenario-specific wrappers
│   └── shared/
│       ├── terraform-modules/   # 16 custom modules
│       └── bicep/               # Reusable Bicep modules
├── .github/
│   ├── workflows/               # CI/CD pipelines ⚠️ BEING REMOVED — deployment workflows and reusable templates moving to bootstrap repos
│   │   ├── scenario1.terraform.yml        # ⚠️ Being removed
│   │   ├── scenario1.bicep.yml            # ⚠️ Being removed
│   │   ├── .template.terraform.yml        # ⚠️ Being removed (reusable template)
│   │   └── .template.bicep.yml            # ⚠️ Being removed (reusable template)
│   └── actions/templates/       # ⚠️ BEING REMOVED — composite actions replaced by bootstrap repo workflows
│       ├── tfValidatePlan/                # ⚠️ Being removed
│       └── tfApply/                       # ⚠️ Being removed
├── sampleapp/                   # ASP.NET Core sample workload
└── docs/                        # Architecture guidance (6 design areas)
```

> **⚠️ Scope Note:** The current repo includes hub networking (Azure Firewall, Bastion, hub VNet, hub-spoke peering). In the target state, **hub networking is removed from this repo's scope**. Users should deploy hub infrastructure using the [ALZ IaC Accelerator](https://aka.ms/alz/acc) and connect their spoke to it via the AVM pattern module's hub integration parameters.

### Terraform Implementation

**Custom Modules (`scenarios/shared/terraform-modules/`):**

| Module Path | Primary Resources | Purpose |
|-------------|------------------|---------|
| `network` | `azurerm_virtual_network`, `azurerm_subnet`, `azurerm_virtual_network_peering` | VNet with subnets and optional peering |
| `firewall` | `azurerm_firewall`, `azurerm_firewall_*_rule_collection`, `azurerm_log_analytics_workspace` | Azure Firewall with rules and diagnostics |
| `bastion` | `azurerm_bastion_host`, `azurerm_public_ip` | Azure Bastion |
| `user-defined-routes` | `azurerm_route_table`, `azurerm_route`, `azurerm_subnet_route_table_association` | Route tables with forced tunneling |
| `private-dns-zone` | `azurerm_private_dns_zone`, `azurerm_private_dns_zone_virtual_network_link`, `azurerm_private_dns_a_record` | Private DNS zones with VNet links and A records |
| `private-endpoint` | `azurerm_private_endpoint`, `azurerm_private_dns_a_record` | Generic private endpoint with DNS integration |
| `app-service` | `azurerm_service_plan`, `azurerm_application_insights`, child modules for Windows/Linux web apps | App Service Plan + App Insights + Web App + VNet integration |
| `app-service/windows-web-app` | `azurerm_windows_web_app`, `azurerm_windows_web_app_slot`, `azurerm_monitor_diagnostic_setting` | Windows Web App with slots and diagnostics |
| `app-service/linux-web-app` | `azurerm_linux_web_app`, `azurerm_linux_web_app_slot`, `azurerm_monitor_diagnostic_setting` | Linux Web App with slots and diagnostics |
| `app-configuration` | `azurerm_app_configuration`, `azurerm_private_endpoint`, `azurerm_role_assignment` | App Configuration with private endpoint and RBAC |
| `key-vault` | `azurerm_key_vault`, `azurerm_role_assignment`, `azurerm_private_endpoint` | Key Vault with RBAC and private endpoint |
| `sql-database` | `azurerm_mssql_server`, `azurerm_mssql_database`, `azurerm_key_vault_secret`, `azurerm_private_endpoint` | SQL Database with password in Key Vault and private endpoint |
| `redis` | `azurerm_redis_cache`, `azurerm_private_endpoint` | Redis Cache with private endpoint |
| `cognitive-services/openai` | `azurerm_cognitive_account`, `azurerm_cognitive_deployment` | Azure OpenAI with model deployments |
| `openai` | `azurerm_cognitive_account`, `azurerm_cognitive_deployment` | Duplicate/legacy OpenAI module |
| `frontdoor` | `azurerm_cdn_frontdoor_profile`, `azurerm_cdn_frontdoor_firewall_policy`, child endpoint module | Front Door with WAF policy |
| `frontdoor/endpoint` | `azurerm_cdn_frontdoor_endpoint`, `azurerm_cdn_frontdoor_origin_group`, `azurerm_cdn_frontdoor_origin`, `azurerm_cdn_frontdoor_route` | Front Door endpoint with private link to App Service |
| `windows-vm` | `azurerm_windows_virtual_machine`, `azurerm_network_interface`, `random_password`, `azurerm_role_assignment` | Windows VM with Entra login and secrets in Key Vault |
| `windows-vm-ext` | `azurerm_virtual_machine_extension` | VM extensions for Entra login and SSMS |

**Hub/Spoke Architecture:**

- **Hub** (`scenarios/secure-baseline-multitenant/terraform/hub/`) — ⚠️ **OUT OF SCOPE (being removed)**:
  - `network.tf` — Hub VNet, Firewall, Bastion
  - `main.tf` — Hub resource group
  - Uses: `network`, `firewall`, `bastion` modules
  - **→ Users should deploy hub infrastructure via the [ALZ IaC Accelerator](https://aka.ms/alz/acc)**

- **Spoke** (`scenarios/secure-baseline-multitenant/terraform/spoke/`):
  - `network.tf` — Spoke VNet, subnets, peering, private DNS zones, Front Door, UDRs
  - `app.tf` — App Service, Key Vault, SQL, App Configuration, Redis
  - `ai.tf` — OpenAI
  - `devops.tf` — Jump host VM
  - `identity.tf` — User-assigned identities
  - `monitoring.tf` — Log Analytics
  - `asev3.tf` — ASE v3 (inline resource, not module)
  - Uses: `network`, `app-service`, `key-vault`, `sql-database`, `redis`, `openai`, `app-configuration`, `frontdoor`, `private-dns-zone`, `private-endpoint`, `user-defined-routes`, `windows-vm`, `windows-vm-ext` modules

**Terraform Provider Versions:**
- AzureRM: `~>4.5.0` (root), `>=4.0` (modules)
- AzureCAF: `>=1.2.23`
- Terraform: `>=1.3`

**Current CI/CD Pattern (Terraform):** ⚠️ **BEING REMOVED** — these template workflows and composite actions will be deleted. CI/CD will come entirely from the OIDC bootstrap repos ([`Azure-Samples/github-terraform-oidc-ci-cd`](https://github.com/Azure-Samples/github-terraform-oidc-ci-cd), [`Azure-Samples/azure-devops-terraform-oidc-ci-cd`](https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd)).

- **Workflows:** `.github/workflows/scenario1.terraform.yml` calls `.github/workflows/.template.terraform.yml` — ⚠️ being removed
- **Actions:** Composite actions in `.github/actions/templates/tfValidatePlan/` and `tfApply/` — ⚠️ being removed
- **Pattern:**
  - OIDC login to Azure (`azure/login@v2`, `ARM_USE_OIDC=true`)
  - `terraform init` with backend config (RG, storage account, container, key)
  - `terraform validate`
  - `tfsec` PR comments
  - `terraform plan` → artifact
  - PR comment with plan output
  - `terraform apply` from artifact
- **State Bootstrap:** `.github/workflows/platform.terraform-dependencies.yml` creates storage account for state

---

### Bicep Implementation

**Shared Modules (`scenarios/shared/bicep/`):**

| Module Path | Primary Resources | Purpose |
|-------------|------------------|---------|
| `naming.module.bicep` | None (helper) | Naming convention generator |
| `managed-identity.bicep` | `Microsoft.ManagedIdentity/userAssignedIdentities` | User-assigned managed identity |
| `role-assignments/role-assignment.bicep` | `Microsoft.Resources/deployments` | Generic RBAC wrapper |
| `private-dns-zone.bicep` | `Microsoft.Network/privateDnsZones`, `virtualNetworkLinks`, `A` records | Private DNS zone with VNet links |
| `private-endpoint.bicep` | `Microsoft.Network/privateEndpoints`, `privateDnsZoneGroups` | Private endpoint with DNS zone group |
| `network/vnet.bicep` | `Microsoft.Network/virtualNetworks` | VNet with subnets |
| `network/udr.bicep` | `Microsoft.Network/routeTables` | Route table |
| `network/nsg.bicep` | `Microsoft.Network/networkSecurityGroups`, diagnostics | NSG with diagnostics |
| `network/peering.bicep` | `Microsoft.Network/virtualNetworks/virtualNetworkPeerings` | VNet peering |
| `network/nic.private.dynamic.bicep` | `Microsoft.Network/networkInterfaces` | Network interface |
| `network/bastion.bicep` | `Microsoft.Network/bastionHosts`, `publicIPAddresses` | Bastion host |
| `network/front-door.bicep` | `Microsoft.Cdn/profiles`, `afdEndpoints`, `originGroups`, `origins`, `routes`, `securitypolicies`, WAF policy | Front Door with WAF |
| `network/publicIPAddresses/main.bicep` | `Microsoft.Network/publicIPAddresses`, locks, diagnostics, RBAC | Public IP with full features |
| `network/azureFirewalls/main.bicep` | `Microsoft.Network/azureFirewalls`, locks, diagnostics, RBAC | Azure Firewall |
| `app-services/app-service-plan.bicep` | `Microsoft.Web/serverfarms`, diagnostics | App Service Plan |
| `app-services/web-app.bicep` | `Microsoft.Web/sites`, `hostNameBindings`, diagnostics, calls appsettings/slots | Web App with slots |
| `app-services/web-app.appsettings.bicep` | `Microsoft.Web/sites/config` | App settings merge |
| `app-services/web-app.slots.bicep` | `Microsoft.Web/sites/slots`, diagnostics, calls slot appsettings | Deployment slots |
| `app-services/web-app.slots.appsettings.bicep` | `Microsoft.Web/sites/slots/config` | Slot app settings |
| `app-services/ase/ase.bicep` | `Microsoft.Web/hostingEnvironments`, locks, diagnostics | ASE v3 |
| `app-services/ase/ase.networking-configuration.bicep` | `Microsoft.Web/hostingEnvironments/configurations` | ASE networking config |
| `app-services/ase/ase.custom-dns-configuration.bicep` | `Microsoft.Web/hostingEnvironments/configurations` | ASE custom DNS |
| `compute/jumphost-win11.bicep` | `Microsoft.Compute/virtualMachines`, extensions | Windows 11 jump host |
| `log-analytics-ws.bicep` | `Microsoft.OperationalInsights/workspaces` | Log Analytics workspace |
| `app-insights.bicep` | `Microsoft.Insights/components` | Application Insights |
| `keyvault.bicep` | `Microsoft.KeyVault/vaults` | Key Vault |
| `app-configuration.bicep` | `Microsoft.AppConfiguration/configurationStores` | App Configuration |
| `databases/sql.bicep` | `Microsoft.Sql/servers`, `databases`, `transparentDataEncryption` | SQL Database |
| `databases/redis.bicep` | `Microsoft.Cache/redis`, diagnostics, Key Vault secret | Redis Cache |
| `storage/storage.bicep` | `Microsoft.Storage/storageAccounts` | Storage account |
| `storage/storage.blobsvc.bicep` | `Microsoft.Storage/storageAccounts`, `blobServices`, containers | Blob storage with containers |
| `storage/storage.queuesvc.bicep` | `Microsoft.Storage/storageAccounts`, `queueServices`, queues | Queue storage |
| `storage/storage.tablesvc.bicep` | `Microsoft.Storage/storageAccounts`, `tableServices`, tables | Table storage |
| `cognitive-services/open-ai.bicep` | `Microsoft.CognitiveServices/accounts`, locks, diagnostics, RBAC, CMK | OpenAI/Cognitive Services with full features |
| `cognitive-services/open-ai.Gpt.deployment.bicep` | `Microsoft.CognitiveServices/accounts/deployments` | GPT model deployment |

**Scenario-Specific Modules (`scenarios/secure-baseline-multitenant/bicep/modules/`):**

These are composition layers that wire shared modules together for the secure baseline scenario:

| Module | Purpose |
|--------|---------|
| `app-service.module.bicep` | Composes App Service Plan + Web App + App Insights + optional ASE + private endpoint/DNS + managed identity + RBAC |
| `keyvault.module.bicep` | Wraps Key Vault + private DNS zone + private endpoint |
| `redis.module.bicep` | Wraps Redis + private DNS zone + private endpoint |
| `sql-database.module.bicep` | Wraps SQL Database + private DNS zone + private endpoint |
| `open-ai.module.bicep` | Wraps OpenAI + optional GPT deployment + private DNS zone + private endpoint |
| `vmJumphost.module.bicep` | Wraps jump host VM + managed identity + Key Vault/App Config RBAC |
| `firewall-basic.module.bicep` | Wraps Azure Firewall Basic |
| `peerings.deployment.bicep` | Creates bidirectional VNet peering |
| `approve-afd-pe.module.bicep` | Deployment script to auto-approve AFD private endpoint connections |

**Top-Level Orchestration (`scenarios/secure-baseline-multitenant/bicep/`):**

- `main.bicep` — Subscription-level deployment, creates RGs, calls hub/spoke deployments
- `deploy.hub.bicep` — Hub VNet, Bastion, Log Analytics, Firewall — ⚠️ **OUT OF SCOPE (being removed; see [ALZ IaC Accelerator](https://aka.ms/alz/acc))**
- `deploy.spoke.bicep` — Spoke VNet, NSGs, UDR, Key Vault, App Service, AFD, optional Redis/SQL/OpenAI/App Config/VM

**Current CI/CD Pattern (Bicep):** ⚠️ **BEING REMOVED** — these template workflows will be deleted. CI/CD will come entirely from the OIDC bootstrap repos.

- **Workflows:** `.github/workflows/scenario1.bicep.yml` calls `.github/workflows/.template.bicep.yml` — ⚠️ being removed
- **Pattern:**
  - OIDC login to Azure (`azure/login@v2`)
  - `az bicep build` for validation
  - `az stack sub create` for deployment (uses Azure Deployment Stacks)
  - `az stack delete --delete-all` for cleanup
  - Deploy only on `main` branch or manual dispatch
  - PSRule integration planned but commented out

---

## Target State

### Vision

The refactored repository will:

1. **Deploy spoke-only workload infrastructure** — This repo focuses exclusively on the App Service workload spoke. Hub networking (VNet hub, Azure Firewall, Bastion, hub-spoke peering) is deployed separately using the [ALZ IaC Accelerator](https://aka.ms/alz/acc). The AVM pattern modules support ALZ integration via input parameters for hub peering and centralized routing.
2. **Use AVM pattern modules as the primary building blocks** — A single pattern module call deploys the entire App Service spoke (networking, App Service, Front Door/App Gateway, Key Vault, ACR, Storage, diagnostics, private endpoints, DNS, RBAC). This replaces the need for 16+ Terraform and 24+ Bicep custom modules.
3. **Supplement with AVM resource modules where needed** — For features not covered by the pattern module (e.g., SQL Database, Redis, OpenAI, App Configuration), use individual AVM resource modules
4. **Flatten the repository structure** — Remove `scenarios/secure-baseline-multitenant/` nesting; implementations live under `infra/terraform/` and `infra/bicep/` at the repo root
5. **Preserve Landing Zone Accelerator value** — Keep configuration/parameterization, documentation, and sample application
6. **Provide CI/CD bootstrap** — Integrate OIDC-based bootstrap for GitHub Actions and Azure DevOps
7. **Maintain backward compatibility where possible** — Document migration paths for existing deployments

### Repository Structure (Post-Refactoring)

```
appservice-landing-zone-accelerator/
├── infra/
│   ├── terraform/                 # Terraform implementation using AVM pattern module
│   │   ├── main.tf               # Calls AVM pattern module + supplemental resource modules
│   │   ├── variables.tf          # Configuration/parameterization for pattern module
│   │   ├── outputs.tf            # Expose pattern module outputs
│   │   └── supplemental.tf       # Individual AVM resource modules for gaps (SQL, Redis, OpenAI, etc.)
│   └── bicep/                     # Bicep implementation using AVM pattern module
│       ├── main.bicep             # Calls AVM pattern module + supplemental resource modules
│       ├── modules/               # Thin wrappers for supplemental resources (kept, simplified)
│       └── main.bicepparam        # Parameter file for pattern module
├── bootstrap/                     # CI/CD bootstrapping (OIDC)
│   ├── github-actions/            # GitHub OIDC bootstrap
│   ├── azure-devops/              # Azure DevOps OIDC bootstrap
│   └── README.md
├── .github/
│   └── workflows/                 # Squad automation only (squad-heartbeat, squad-triage, etc.) — no deployment workflows
├── sampleapp/                     # UNCHANGED
├── docs/                          # UPDATED — hub content removed, ALZ reference added
│   └── migration-guide.md         # NEW: Migration guide for existing deployments
└── .squad/                        # Team state
```

> **⚠️ Structure Change:** The previous `scenarios/secure-baseline-multitenant/{terraform,bicep}/` nesting has been flattened to `infra/{terraform,bicep}/`. The `scenarios/shared/terraform-modules/` and `scenarios/shared/bicep/` directories are removed entirely (replaced by AVM pattern modules). Hub-specific files (`hub/`, `deploy.hub.bicep`) are removed — hub networking is provisioned via the [ALZ IaC Accelerator](https://aka.ms/alz/acc).

### AVM Module Strategy

**Principles:**
- **Pattern Module First** — Use the AVM pattern module for the complete App Service Landing Zone deployment
- **Resource Module Fallback** — Use individual AVM resource modules only for capabilities not covered by the pattern module
- **Thin Wrappers** — Keep scenario-specific modules as thin composition/configuration layers
- **Document Gaps** — Clearly document where the pattern module doesn't cover our needs
- **Version Pinning** — Pin AVM module versions for stability

**AVM Module Sources:**
- **Terraform Pattern:** `registry.terraform.io/modules/Azure/avm-ptn-app-service-landing-zone/azure`
- **Terraform Resources:** `registry.terraform.io/modules/Azure/` (e.g., `Azure/avm-res-network-virtualnetwork/azurerm`)
- **Bicep Pattern:** `br/public:avm/ptn/app-service-lza/hosting-environment`
- **Bicep Resources:** `br/public:avm/res.*` (e.g., `br/public:avm/res/network/virtual-network`)

### Pattern Module Strategy

> **⚠️ MAJOR STRATEGIC SHIFT:** The AVM pattern modules for App Service Landing Zone fundamentally change our migration approach. Instead of replacing 16+ Terraform and 24+ Bicep custom modules one-by-one with individual AVM resource modules, we can deploy the entire landing zone with a single pattern module call. This is a massive simplification.

**What the Pattern Modules Deploy (Single Module Call):**

| Capability | Terraform Pattern Module | Bicep Pattern Module |
|-----------|-------------------------|---------------------|
| App Service Plans (Linux/Windows/ASEv3) | ✅ | ✅ |
| Multiple Web Apps with slots, managed identities | ✅ | ✅ |
| Azure Front Door (Premium + WAF) | ✅ | ✅ |
| Application Gateway (WAF v2) | ✅ | ✅ |
| VNet with purpose-built subnets | ✅ | ✅ |
| Hub-spoke peering & ALZ route table integration | ✅ | ✅ |
| Private DNS zones (App Service, Key Vault, Storage, ACR) | ✅ | ✅ |
| Private endpoints for all resources | ✅ | ✅ |
| Key Vault with secrets, RBAC | ✅ | ✅ |
| Application Insights + Log Analytics | ✅ | ✅ |
| Azure Container Registry (Premium, zone-redundant) | ✅ | ✅ |
| Storage account with blob/file, firewall rules, private endpoints | ✅ | ✅ |
| Azure Bastion Host | ✅ | ✅ |
| WAF policies, RBAC, managed identities | ✅ | ✅ |
| Bring-Your-Own resources (existing VNet, Key Vault, ACR) | ✅ | ✅ |
| Diagnostic settings | ✅ | ✅ |

**Pattern Module References:**

| | Terraform | Bicep |
|--|-----------|-------|
| **Registry** | `Azure/avm-ptn-app-service-landing-zone/azure` | `br/public:avm/ptn/app-service-lza/hosting-environment` (v0.2) |
| **GitHub** | `Azure/terraform-azure-avm-ptn-app-service-landing-zone` | `Azure/bicep-registry-modules` → `avm/ptn/app-service-lza/hosting-environment` |
| **Requirements** | Terraform >= 1.9, AzureRM ~> 4.0, azapi ~> 2.4 | Bicep CLI (latest) |

**What the Pattern Module Replaces:**

The pattern module replaces the ENTIRE set of custom modules with a single module call:

| Custom Modules Replaced | Count (Terraform) | Count (Bicep) |
|------------------------|-------------------|---------------|
| Networking (VNet, subnets, peering, UDR, NSG) | 2 | 5 |
| Private DNS zones | 1 | 1 |
| Private endpoints | 1 | 1 |
| App Service (Plan + Web Apps + slots) | 4 | 5 |
| Key Vault | 1 | 1 |
| Front Door / Application Gateway | 2 | 1 |
| Bastion | 1 | 1 |
| Storage | 0 | 4 |
| Monitoring (Log Analytics + App Insights) | 0 | 2 |
| Managed Identity | 0 | 1 |
| **Total replaced by ONE pattern module call** | **12** | **22** |

**What the Pattern Module Does NOT Cover (Supplemental Resource Modules Needed):**

> **Note:** Azure Firewall, Bastion, and other hub networking components are **out of scope** for this repo. Users deploy hub infrastructure via the [ALZ IaC Accelerator](https://aka.ms/alz/acc) and connect to the spoke via the pattern module's hub integration parameters (e.g., `hub_virtual_network_id`, `route_table_id`).

| Capability | Terraform AVM Resource Module | Bicep AVM Resource Module |
|-----------|------------------------------|--------------------------|
| SQL Database | `Azure/avm-res-sql-server/azurerm` | `br/public:avm/res/sql/server` |
| Redis Cache | `Azure/avm-res-cache-redis/azurerm` | `br/public:avm/res/cache/redis` |
| App Configuration | `Azure/avm-res-appconfiguration-configurationstore/azurerm` | `br/public:avm/res/app-configuration/configuration-store` |
| Azure OpenAI / Cognitive Services | `Azure/avm-res-cognitiveservices-account/azurerm` | `br/public:avm/res/cognitive-services/account` |
| Windows VM (Jump Host) | `Azure/avm-res-compute-virtualmachine/azurerm` | `br/public:avm/res/compute/virtual-machine` |

> **Note:** The supplemental modules above represent capabilities that are specific to the Landing Zone Accelerator scenarios but not part of the core App Service hosting environment that the pattern module provides. The pattern module focuses on the hosting platform; data services, AI, and jump hosts are supplemental. Hub networking (Firewall, Bastion, hub VNet) is provisioned separately via the [ALZ IaC Accelerator](https://aka.ms/alz/acc).

**How This Changes the Repo's Role:**

With the pattern module doing the heavy lifting, the repo's value shifts from *infrastructure code* to:

1. **Configuration & Parameterization** — Curated variable files and tfvars/bicepparam that configure the pattern module for the spoke workload, including hub integration parameters (hub VNet ID, route table, etc.) that connect to an existing ALZ hub
2. **Scenario-Specific Supplements** — Individual AVM resource modules for capabilities not covered by the pattern module (SQL, Redis, OpenAI, etc.)
3. **CI/CD Bootstrapping** — OIDC bootstrap for GitHub Actions and Azure DevOps (unchanged)
4. **Documentation & Guidance** — Architecture guidance, getting-started guides, migration guides, and a reference to the [ALZ IaC Accelerator](https://aka.ms/alz/acc) for hub networking
5. **Sample Application** — ASP.NET Core sample workload (unchanged)

---

## Workstream 1: Terraform AVM Migration

### Objective

Replace custom Terraform modules in `scenarios/shared/terraform-modules/` with the AVM **pattern module** (`Azure/avm-ptn-app-service-landing-zone/azure`) as the primary deployment mechanism, supplemented by individual AVM resource modules for capabilities the pattern module doesn't cover. Move implementation from `scenarios/secure-baseline-multitenant/terraform/` to `infra/terraform/`. Hub networking is out of scope — users connect to their existing ALZ hub via the pattern module's input parameters.

### Primary: Pattern Module Mapping

The pattern module replaces the majority of custom modules with a single module call:

| Custom Modules | Pattern Module | What It Replaces |
|---------------|---------------|-----------------|
| `network`, `user-defined-routes`, `private-dns-zone`, `private-endpoint`, `bastion`, `app-service` (plan + web apps), `key-vault`, `frontdoor` (+ `frontdoor/endpoint`) | `Azure/avm-ptn-app-service-landing-zone/azure` | VNet with subnets, peering, UDRs, private DNS zones, private endpoints, App Service Plans, Web Apps with slots, Front Door/App Gateway with WAF, Key Vault, Bastion, Storage, ACR, App Insights, Log Analytics, managed identities, RBAC, diagnostic settings |

**Pattern Module Requirements:** Terraform >= 1.9, AzureRM ~> 4.0, azapi ~> 2.4

### Supplemental: AVM Resource Module Mapping

These individual resource modules fill gaps not covered by the pattern module:

| Custom Module | AVM Resource Module | Notes |
|---------------|---------------------|-------|
| `sql-database` | `Azure/avm-res-sql-server/azurerm` | SQL Server and Database with private endpoint |
| `redis` | `Azure/avm-res-cache-redis/azurerm` | Redis Cache with private endpoint |
| `app-configuration` | `Azure/avm-res-appconfiguration-configurationstore/azurerm` | App Configuration with private endpoint and RBAC |
| `cognitive-services/openai` + `openai` | `Azure/avm-res-cognitiveservices-account/azurerm` | Cognitive Services (OpenAI) with deployments; removes duplicate module |
| `windows-vm` + `windows-vm-ext` | `Azure/avm-res-compute-virtualmachine/azurerm` | VM with managed identity, extensions, diagnostics |

> **Note:** The `firewall` and `bastion` custom modules are no longer needed — hub networking is provisioned via the [ALZ IaC Accelerator](https://aka.ms/alz/acc). The pattern module supports hub integration via input parameters (e.g., `hub_virtual_network_id`).

### Fallback: Individual AVM Resource Module Mapping

> **Reference Only** — If the pattern module doesn't cover specific scenarios, the full individual-module mapping is preserved below as a fallback strategy. In the primary approach, these are NOT needed for resources covered by the pattern module.

| Custom Module | AVM Module | Notes |
|---------------|------------|-------|
| `network` | `Azure/avm-res-network-virtualnetwork/azurerm` | Includes VNet, subnets, NSG associations, route table associations, peering |
| `firewall` | `Azure/avm-res-network-azurefirewall/azurerm` | Includes firewall, public IP, diagnostics, application/network rules |
| `bastion` | `Azure/avm-res-network-bastionhost/azurerm` | Includes bastion host and public IP |
| `user-defined-routes` | `Azure/avm-res-network-routetable/azurerm` | Route table with routes and subnet associations |
| `private-dns-zone` | `Azure/avm-res-network-privatednszone/azurerm` | Private DNS zones with VNet links and A records |
| `private-endpoint` | `Azure/avm-res-network-privateendpoint/azurerm` | Private endpoint with DNS zone group integration |
| `app-service` (plan) | `Azure/avm-res-web-serverfarm/azurerm` | App Service Plan |
| `app-service` (web app) | `Azure/avm-res-web-site/azurerm` | Web App (Windows/Linux) with slots, diagnostics, VNet integration |
| `app-configuration` | `Azure/avm-res-appconfiguration-configurationstore/azurerm` | App Configuration with private endpoint and RBAC |
| `key-vault` | `Azure/avm-res-keyvault-vault/azurerm` | Key Vault with RBAC, private endpoint, diagnostics |
| `sql-database` | `Azure/avm-res-sql-server/azurerm` + `Azure/avm-res-sql-database/azurerm` | SQL Server and Database with private endpoint |
| `redis` | `Azure/avm-res-cache-redis/azurerm` | Redis Cache with private endpoint |
| `cognitive-services/openai` | `Azure/avm-res-cognitiveservices-account/azurerm` | Cognitive Services (OpenAI) with deployments |
| `frontdoor` | `Azure/avm-res-cdn-profile/azurerm` | Front Door (CDN) profile with WAF, endpoints, origins, routes |
| `windows-vm` | `Azure/avm-res-compute-virtualmachine/azurerm` | Virtual Machine with managed identity, diagnostics, extensions |
| `windows-vm-ext` | Included in VM module | VM extensions (Entra login, custom scripts) |

**Note:** Module names are based on AVM naming conventions (as of 2024). Verify exact names in registry before implementation.

### Breaking Changes & Migration Considerations

| Area | Breaking Change | Migration Strategy |
|------|----------------|-------------------|
| **Module Inputs** | Pattern module uses a different input structure than individual custom modules | Create variable mapping layer that translates existing tfvars into pattern module inputs |
| **Module Outputs** | Pattern module output structure differs significantly | Update all output references; provide output mapping documentation |
| **State Migration** | All resource addresses change when switching from custom modules to pattern module | Document `terraform state mv` commands; provide migration script; recommend blue/green approach |
| **Provider Requirements** | Pattern module requires Terraform >= 1.9, AzureRM ~> 4.0, azapi ~> 2.4 | Update `required_providers` block; test compatibility |
| **Hub/Spoke Simplification** | Hub directory removed entirely; spoke-only deployment | Hub infrastructure provisioned via [ALZ IaC Accelerator](https://aka.ms/alz/acc); pattern module connects to existing hub via input parameters |
| **Folder Structure** | Implementation moves from `scenarios/secure-baseline-multitenant/terraform/` to `infra/terraform/` | Update all CI/CD paths and documentation references |
| **Feature Parity** | Pattern module may not support all custom features (specific rule sets, edge cases) | Validate against all scenarios; use supplemental resource modules or inline resources for gaps |
| **Diagnostics** | Pattern module uses consistent diagnostics interface | Update diagnostics configuration to match pattern module parameters |
| **RBAC** | Pattern module manages RBAC internally | Review and update any external RBAC assignments |

### Implementation Phases

> **Note:** The pattern module approach dramatically simplifies phasing from 7 phases to 5.

**Phase 1: Pattern Module Validation**
- [ ] Deploy the Terraform pattern module (`Azure/avm-ptn-app-service-landing-zone/azure`) in isolation
- [ ] Map existing `terraform.tfvars` inputs to pattern module variables
- [ ] Validate it covers: VNet, subnets, peering, App Service Plan, Web Apps, Front Door/App GW, Key Vault, Bastion, Storage, ACR, App Insights, Log Analytics, private endpoints, DNS
- [ ] Document any gaps where the pattern module doesn't match current functionality
- [ ] Verify ASE v3 scenario is supported via the pattern module
- [ ] Test BYO (Bring-Your-Own) resource support for existing VNet, Key Vault, ACR

**Phase 2: Configure Pattern Module for Spoke Deployment**
- [ ] Create `infra/terraform/main.tf` that calls the pattern module with secure-baseline configuration
- [ ] Add supplemental AVM resource modules for: SQL Database, Redis, App Configuration, OpenAI, VM (jump host)
- [ ] Wire supplemental modules to pattern module outputs (e.g., VNet ID, subnet IDs, Key Vault ID)
- [ ] Create comprehensive `variables.tf` and `terraform.tfvars` for the scenario
- [ ] Configure hub integration parameters (hub VNet ID, route table) for users connecting to an existing ALZ hub
- [ ] Verify private endpoints and DNS resolution for supplemental resources

**Phase 3: Test and Validate**
- [ ] End-to-end deployment test (multitenant scenario)
- [ ] End-to-end deployment test (ASE v3 scenario)
- [ ] Verify sample app deploys and runs
- [ ] Performance and drift detection testing
- [ ] Compare deployed resources against current implementation (parity check)
- [ ] Test `terraform plan` for no-change scenarios (idempotency)

**Phase 4: State Migration and Documentation**
- [ ] Remove legacy deployment workflows (`.template.terraform.yml`, `scenario1.terraform.yml`) and composite actions (`tfValidatePlan/`, `tfApply/`) — CI/CD now comes from OIDC bootstrap repos
- [ ] Document `terraform state mv` commands for migrating from custom modules to pattern module
- [ ] Create state migration script
- [ ] Test state migration in non-production environment
- [ ] Document blue/green migration approach for zero-downtime transitions

**Phase 5: Cleanup and Documentation**
- [ ] Remove custom modules from `scenarios/shared/terraform-modules/` (or archive)
- [ ] Remove hub directory (`scenarios/secure-baseline-multitenant/terraform/hub/`)
- [ ] Move spoke implementation to `infra/terraform/`
- [ ] Remove `scenarios/` directory once migration is complete
- [ ] Update README with pattern module usage instructions and ALZ IaC Accelerator reference for hub networking
- [ ] Create migration guide for existing deployments
- [ ] Document variable mapping (old tfvars → new pattern module inputs)
- [ ] Document hub integration parameters for connecting to existing ALZ hub

### Validation Criteria

- ✅ All custom modules replaced or justified
- ✅ Spoke deployment succeeds with AVM pattern module (connected to existing ALZ hub)
- ✅ ASE v3 scenario works
- ✅ Private endpoints and DNS function correctly
- ✅ Diagnostics and monitoring work
- ✅ RBAC assignments function correctly
- ✅ Sample app deploys and runs
- ✅ State migration documented and tested
- ✅ Implementation lives under `infra/terraform/`

---

## Workstream 2: Bicep AVM Migration

### Objective

Replace custom Bicep modules in `scenarios/shared/bicep/` with the AVM **pattern module** (`br/public:avm/ptn/app-service-lza/hosting-environment`) as the primary deployment mechanism, supplemented by individual AVM resource modules for capabilities the pattern module doesn't cover. Move implementation from `scenarios/secure-baseline-multitenant/bicep/` to `infra/bicep/`. Simplify scenario-specific composition modules. Hub networking is out of scope — users connect to their existing ALZ hub via the pattern module's input parameters.

### Primary: Pattern Module Mapping

The pattern module replaces the majority of custom Bicep modules with a single module call:

| Custom Modules | Pattern Module | What It Replaces |
|---------------|---------------|-----------------|
| `network/vnet.bicep`, `network/nsg.bicep`, `network/udr.bicep`, `network/peering.bicep`, `network/bastion.bicep`, `network/publicIPAddresses/main.bicep`, `network/front-door.bicep`, `private-dns-zone.bicep`, `private-endpoint.bicep`, `app-services/app-service-plan.bicep`, `app-services/web-app.bicep` (+ slots/appsettings), `keyvault.bicep`, `log-analytics-ws.bicep`, `app-insights.bicep`, `managed-identity.bicep`, and most scenario wrappers | `br/public:avm/ptn/app-service-lza/hosting-environment` (v0.2) | VNet, NSGs, UDRs, peering, Front Door/App GW with WAF, private DNS zones, private endpoints, App Service Plans, Web Apps with slots, Key Vault with secrets, App Insights, Log Analytics, Bastion, Storage, ACR, managed identities, federated credentials, RBAC, locks, diagnostic settings |

### Supplemental: AVM Resource Module Mapping

These individual resource modules fill gaps not covered by the pattern module:

| Custom Module | AVM Resource Module | Notes |
|---------------|---------------------|-------|
| `databases/sql.bicep` | `br/public:avm/res/sql/server` | SQL Server and databases |
| `databases/redis.bicep` | `br/public:avm/res/cache/redis` | Redis Cache |
| `app-configuration.bicep` | `br/public:avm/res/app-configuration/configuration-store` | App Configuration with RBAC |
| `cognitive-services/open-ai.bicep` (+ GPT deployment) | `br/public:avm/res/cognitive-services/account` | Cognitive Services (OpenAI) with deployments |
| `compute/jumphost-win11.bicep` | `br/public:avm/res/compute/virtual-machine` | Virtual Machine with extensions |
| `storage/storage.queuesvc.bicep`, `storage/storage.tablesvc.bicep` | `br/public:avm/res/storage/storage-account` | Queue/Table storage (if not covered by pattern module's storage) |

> **Note:** The `network/azureFirewalls/main.bicep`, `network/bastion.bicep`, and other hub-related modules are no longer needed — hub networking is provisioned via the [ALZ IaC Accelerator](https://aka.ms/alz/acc).

### Fallback: Individual AVM Resource Module Mapping

> **Reference Only** — If the pattern module doesn't cover specific scenarios, the full individual-module mapping is preserved below as a fallback strategy.

| Custom Module | AVM Module | Notes |
|---------------|------------|-------|
| `network/vnet.bicep` | `br/public:avm/res/network/virtual-network` | VNet with subnets, NSGs, route tables |
| `network/nsg.bicep` | Included in VNet module | NSG with diagnostics |
| `network/udr.bicep` | `br/public:avm/res/network/route-table` | Route table with routes |
| `network/peering.bicep` | Included in VNet module | VNet peering |
| `network/bastion.bicep` | `br/public:avm/res/network/bastion-host` | Bastion host with public IP |
| `network/publicIPAddresses/main.bicep` | `br/public:avm/res/network/public-ip-address` | Public IP with locks, diagnostics, RBAC |
| `network/azureFirewalls/main.bicep` | `br/public:avm/res/network/azure-firewall` | Azure Firewall with rules, diagnostics |
| `network/front-door.bicep` | `br/public:avm/res/cdn/profile` | Front Door with endpoints, origins, WAF |
| `private-dns-zone.bicep` | `br/public:avm/res/network/private-dns-zone` | Private DNS zone with VNet links |
| `private-endpoint.bicep` | `br/public:avm/res/network/private-endpoint` | Private endpoint with DNS zone groups |
| `app-services/app-service-plan.bicep` | `br/public:avm/res/web/serverfarm` | App Service Plan |
| `app-services/web-app.bicep` | `br/public:avm/res/web/site` | Web App with slots, diagnostics |
| `app-services/ase/ase.bicep` | `br/public:avm/res/web/hosting-environment` | App Service Environment v3 |
| `keyvault.bicep` | `br/public:avm/res/key-vault/vault` | Key Vault with RBAC, private endpoint |
| `app-configuration.bicep` | `br/public:avm/res/app-configuration/configuration-store` | App Configuration with RBAC |
| `databases/sql.bicep` | `br/public:avm/res/sql/server` | SQL Server and databases |
| `databases/redis.bicep` | `br/public:avm/res/cache/redis` | Redis Cache |
| `storage/storage.*.bicep` | `br/public:avm/res/storage/storage-account` | Storage account with blob/queue/table services |
| `cognitive-services/open-ai.bicep` | `br/public:avm/res/cognitive-services/account` | Cognitive Services (OpenAI) with deployments |
| `log-analytics-ws.bicep` | `br/public:avm/res/operational-insights/workspace` | Log Analytics workspace |
| `app-insights.bicep` | `br/public:avm/res/insights/component` | Application Insights |
| `managed-identity.bicep` | `br/public:avm/res/managed-identity/user-assigned-identity` | User-assigned managed identity |
| `compute/jumphost-win11.bicep` | `br/public:avm/res/compute/virtual-machine` | Virtual Machine with extensions |

**Scenario-Specific Modules (`modules/`) — Simplification:**
- With the pattern module, most scenario-specific wrappers (`app-service.module.bicep`, `keyvault.module.bicep`, etc.) become **unnecessary** because the pattern module handles the composition internally
- Remaining wrappers may be needed only for supplemental resources (SQL, Redis, OpenAI, VM) to wire private endpoints and RBAC
- The `approve-afd-pe.module.bicep` may still be needed if the pattern module doesn't handle AFD private endpoint auto-approval

### Breaking Changes & Migration Considerations

| Area | Breaking Change | Migration Strategy |
|------|----------------|-------------------|
| **Parameter Names** | Pattern module uses its own parameter schema | Create parameter mapping from existing bicepparam to pattern module inputs |
| **Output Structure** | Pattern module outputs are different from custom module outputs | Update output references in orchestration |
| **Deployment Scope** | Pattern module may deploy at resource group level vs. current subscription-level orchestration | Adjust `main.bicep` orchestration to work with pattern module deployment model |
| **Hub Removal** | `deploy.hub.bicep` and hub-related modules removed entirely | Hub infrastructure provisioned via [ALZ IaC Accelerator](https://aka.ms/alz/acc); spoke connects via pattern module hub integration parameters |
| **Folder Structure** | Implementation moves from `scenarios/secure-baseline-multitenant/bicep/` to `infra/bicep/` | Update all CI/CD paths and documentation references |
| **Scenario Wrappers** | Most wrappers become unnecessary (pattern module handles composition) | Remove or simplify wrappers; keep only for supplemental resources |
| **Diagnostics** | Pattern module manages diagnostic settings internally | Remove separate diagnostics configuration for resources covered by pattern module |
| **RBAC** | Pattern module manages RBAC internally | Review and update external RBAC assignments |
| **Module Registry** | Switching to `br/public:avm/ptn/*` and `br/public:avm/res/*` references | Update all module references; version pinning recommended |

### Implementation Phases

> **Note:** The pattern module approach dramatically simplifies phasing from 7 phases to 5.

**Phase 1: Pattern Module Validation**
- [ ] Deploy the Bicep pattern module (`br/public:avm/ptn/app-service-lza/hosting-environment`) in isolation
- [ ] Map existing `main.bicepparam` inputs to pattern module parameters
- [ ] Validate it covers: VNet, subnets, peering, App Service Plan, Web Apps, Front Door/App GW with WAF, Key Vault, Bastion, Storage, ACR, App Insights, Log Analytics, managed identities, private endpoints, DNS, NSGs
- [ ] Document any gaps where the pattern module doesn't match current functionality
- [ ] Verify ASE v3 scenario is supported via the pattern module
- [ ] Test BYO (Bring-Your-Own) resource support

**Phase 2: Configure Pattern Module for Spoke Deployment**
- [ ] Create updated `infra/bicep/main.bicep` that calls the pattern module with secure-baseline configuration
- [ ] Add supplemental AVM resource modules for: SQL Database, Redis, App Configuration, OpenAI, VM (jump host)
- [ ] Wire supplemental modules to pattern module outputs (VNet ID, subnet IDs, Key Vault ID)
- [ ] Simplify or remove scenario-specific wrappers that are now handled by the pattern module
- [ ] Configure hub integration parameters for users connecting to an existing ALZ hub
- [ ] Verify private endpoints and DNS resolution for supplemental resources

**Phase 3: Test and Validate**
- [ ] End-to-end deployment test (multitenant scenario)
- [ ] End-to-end deployment test (ASE v3 scenario)
- [ ] Verify sample app deploys and runs
- [ ] Test Azure Deployment Stack compatibility (`az stack sub create`)
- [ ] Verify all feature flags work
- [ ] Compare deployed resources against current implementation (parity check)

**Phase 4: Cleanup and Documentation**
- [ ] Remove legacy deployment workflows (`.template.bicep.yml`, `scenario1.bicep.yml`) — CI/CD now comes from OIDC bootstrap repos
- [ ] Test Deployment Stack update/delete scenarios
- [ ] Create migration guide for existing Bicep deployments
- [ ] Document parameter mapping (old → new)

**Phase 5: Cleanup**
- [ ] Remove custom modules from `scenarios/shared/bicep/` (or archive)
- [ ] Remove hub files (`deploy.hub.bicep`, `firewall-basic.module.bicep`, `peerings.deployment.bicep`)
- [ ] Move spoke implementation to `infra/bicep/`
- [ ] Remove unnecessary scenario-specific wrappers
- [ ] Update README with pattern module usage instructions and ALZ IaC Accelerator reference
- [ ] Update architecture documentation

### Validation Criteria

- ✅ All shared modules replaced with AVM or removed
- ✅ Scenario-specific wrappers updated and validated
- ✅ Spoke deployment succeeds (connected to existing ALZ hub)
- ✅ ASE v3 scenario works
- ✅ Deployment Stacks work correctly
- ✅ All feature flags function
- ✅ Sample app deploys and runs
- ✅ Documentation updated
- ✅ Implementation lives under `infra/bicep/`

---

## Workstream 3: CI/CD Bootstrapping with OIDC

### Objective

Integrate OIDC-based CI/CD bootstrap solutions for GitHub Actions and Azure DevOps, based on proven reference implementations from Microsoft.

### Reference Implementations

**1. GitHub Actions Bootstrap**
- **Source:** `Azure-Samples/github-terraform-oidc-ci-cd`
- **Features:**
  - 6 Azure User Assigned Managed Identities with OIDC federation
  - Azure Storage Account for Terraform state
  - GitHub repository + environments setup (dev/test/prod)
  - Continuous Delivery Action with OIDC auth
  - Pull Request workflow with static analysis
  - Separate plan/apply identities for least privilege
  - Environment approvals and concurrent locks

**2. Azure DevOps Bootstrap**
- **Source:** `Azure-Samples/azure-devops-terraform-oidc-ci-cd`
- **Features:**
  - 6 Azure User Assigned Managed Identities with OIDC federation
  - Azure Storage Account for Terraform state
  - Azure DevOps repository + environments setup (dev/test/prod)
  - Governed pipelines (template repository pattern)
  - Continuous Delivery pipeline with OIDC auth
  - Pull Request workflow with static analysis
  - Separate plan/apply identities
  - Environment approvals and locks

### Integration Strategy

**Repository Structure:**

```
bootstrap/
├── README.md                      # Bootstrap overview and decision guide
├── github-actions/
│   ├── terraform/                 # Terraform for GitHub OIDC bootstrap
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md             # GitHub-specific instructions
│   └── workflows/                 # Example workflows using OIDC
│       ├── continuous-delivery.yml
│       └── pull-request.yml
└── azure-devops/
    ├── terraform/                 # Terraform for Azure DevOps OIDC bootstrap
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md             # Azure DevOps-specific instructions
    └── pipelines/                 # Example pipelines using OIDC
        ├── continuous-delivery.yml
        └── pull-request.yml
```

**Integration Points:**

1. **State Management:**
   - Bootstrap creates storage account for Terraform state
   - Update `backend.hcl.template` to reference bootstrap-created storage
   - Document how to migrate existing state

2. **Workflow Cleanup:**
   - Remove all legacy deployment workflows and composite actions from this repo (`.template.terraform.yml`, `.template.bicep.yml`, `scenario1.terraform.yml`, `scenario1.bicep.yml`, `tfValidatePlan/`, `tfApply/`)
   - `.github/workflows/` will only contain squad automation workflows (squad-heartbeat, squad-triage, etc.)
   - CI/CD workflows live in the bootstrap repos: [`Azure-Samples/github-terraform-oidc-ci-cd`](https://github.com/Azure-Samples/github-terraform-oidc-ci-cd) and [`Azure-Samples/azure-devops-terraform-oidc-ci-cd`](https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd)
   - Users get OIDC login, environment gates (dev/test/prod), and plan/apply identity separation from the bootstrap repos

3. **Environment Strategy:**
   - **Dev:** Auto-deploy on PR merge to `main`
   - **Test:** Manual approval gate
   - **Prod:** Manual approval gate + additional reviewers

4. **Security Posture:**
   - No secrets or service principal credentials in GitHub/Azure DevOps
   - OIDC federated credentials scoped to specific repos/branches
   - Managed identities with least-privilege RBAC

### GitHub Actions Integration

**Managed Identities:**
1. `github-plan-dev` — Terraform plan for dev
2. `github-apply-dev` — Terraform apply for dev
3. `github-plan-test` — Terraform plan for test
4. `github-apply-test` — Terraform apply for test
5. `github-plan-prod` — Terraform plan for prod
6. `github-apply-prod` — Terraform apply for prod

**Workflow Changes:**

**Before (Current):**
```yaml
- name: Azure Login
  uses: azure/login@v2
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

**After (OIDC):**
```yaml
- name: Azure Login (OIDC)
  uses: azure/login@v2
  with:
    client-id: ${{ vars.AZURE_CLIENT_ID_PLAN_DEV }}  # From bootstrap outputs
    tenant-id: ${{ vars.AZURE_TENANT_ID }}
    subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}
    enable-oidc: true
```

**Environment Configuration:**
- Create `dev`, `test`, `prod` environments in GitHub repo settings
- Add protection rules (approvals, reviewers)
- Store bootstrap outputs as environment variables

### Azure DevOps Integration

**Managed Identities:**
1. `azdo-plan-dev` — Terraform plan for dev
2. `azdo-apply-dev` — Terraform apply for dev
3. `azdo-plan-test` — Terraform plan for test
4. `azdo-apply-test` — Terraform apply for test
5. `azdo-plan-prod` — Terraform plan for prod
6. `azdo-apply-prod` — Terraform apply for prod

**Service Connection:**
- Create Azure Resource Manager service connection with Workload Identity Federation
- Use managed identity client ID from bootstrap outputs
- Scope to subscription

**Pipeline Changes:**

**Before (Current):**
```yaml
- task: AzureCLI@2
  inputs:
    azureSubscription: 'Service-Connection-Name'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: 'terraform init'
```

**After (OIDC):**
```yaml
- task: AzureCLI@2
  inputs:
    azureSubscription: 'OIDC-Dev-Plan'  # Workload Identity Federation
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: 'terraform init'
    addSpnToEnvironment: true
    useGlobalConfig: true
```

**Environment Configuration:**
- Create `dev`, `test`, `prod` environments in Azure DevOps
- Add approval gates
- Configure checks and validations

### Implementation Phases

**Phase 1: Bootstrap Setup**
- [ ] Create `bootstrap/` directory structure
- [ ] Adapt GitHub Actions bootstrap from reference repo
- [ ] Adapt Azure DevOps bootstrap from reference repo
- [ ] Document bootstrap prerequisites and steps
- [ ] Test bootstrap in clean environment

**Phase 2: GitHub Actions Migration**
- [ ] Create dev/test/prod environments in GitHub
- [ ] Run GitHub bootstrap to create identities and storage
- [ ] Remove legacy deployment workflows (`.template.terraform.yml`, `.template.bicep.yml`, `scenario1.terraform.yml`, `scenario1.bicep.yml`) and composite actions (`tfValidatePlan/`, `tfApply/`)
- [ ] Verify `.github/workflows/` only contains squad automation workflows (squad-heartbeat, squad-triage, etc.)
- [ ] Test OIDC authentication using bootstrap repo workflows
- [ ] Test plan/apply separation
- [ ] Test environment approvals

**Phase 3: Azure DevOps Setup**
- [ ] Create dev/test/prod environments in Azure DevOps
- [ ] Run Azure DevOps bootstrap to create identities and storage
- [ ] Create example pipelines (not replacing GitHub Actions, just documenting)
- [ ] Document Azure DevOps setup process
- [ ] Test OIDC authentication in Azure DevOps

**Phase 4: Documentation & Examples**
- [ ] Create decision guide (GitHub Actions vs Azure DevOps)
- [ ] Document state migration from existing storage to bootstrap storage
- [ ] Create runbook for bootstrap execution
- [ ] Document RBAC requirements
- [ ] Create troubleshooting guide

**Phase 5: Legacy Support**
- [ ] Document how to continue using service principals (if needed)
- [ ] Provide migration path for existing deployments
- [ ] Create rollback procedure

### Validation Criteria

- ✅ Bootstrap terraform deploys successfully for both platforms
- ✅ OIDC authentication works for plan operations
- ✅ OIDC authentication works for apply operations
- ✅ Environment approvals function correctly
- ✅ Plan/apply identity separation enforced
- ✅ State storage in bootstrap-created account works
- ✅ No secrets or credentials in repo
- ✅ Documentation complete and tested

---

## Non-Goals

### Explicitly Out of Scope

**Hub Networking:**
- ❌ No hub VNet, Azure Firewall, Bastion, or hub-spoke peering deployment in this repo
- ❌ No firewall rule management or Bastion configuration
- ✅ Users deploy hub infrastructure via the [ALZ IaC Accelerator](https://aka.ms/alz/acc)
- ✅ The AVM pattern modules accept hub integration parameters (hub VNet ID, route table) to connect the spoke to an existing hub

**Sample Application:**
- ❌ No changes to `sampleapp/` ASP.NET Core application
- ❌ No changes to application architecture or code
- ✅ Sample app must continue to work with new infrastructure

**Documentation Structure:**
- ❌ No changes to `docs/Design-Areas/` architecture guidance (except removing hub-specific content and adding ALZ IaC Accelerator references)
- ✅ Documentation will be updated to reference AVM modules instead of custom modules
- ✅ New migration guide will be added

**Scenario Structure:**
- ❌ No new scenarios or reference implementations
- ✅ Existing secure-baseline-multitenant scenario remains the focus, restructured under `infra/`

**Azure Services:**
- ❌ No new Azure services added
- ✅ All existing spoke services supported with AVM modules

**Breaking Changes (Where Avoidable):**
- ❌ Do not force immediate migration for existing deployments
- ✅ Document migration paths and provide upgrade scripts
- ✅ Maintain backward compatibility through documentation

**Azure Portal / ARM Deployment:**
- ❌ No Azure Portal deployment option (no "Deploy to Azure" buttons)
- ❌ No ARM JSON templates or `azure-resource-manager/` folder
- ✅ This repo is Terraform and Bicep only

**Custom Deployment Workflows:**
- ❌ No custom deployment workflows in this repo (legacy `.template.terraform.yml`, `.template.bicep.yml`, composite actions removed)
- ❌ No reusable workflow templates maintained in this repo
- ✅ CI/CD handled entirely by the OIDC bootstrap repos ([`Azure-Samples/github-terraform-oidc-ci-cd`](https://github.com/Azure-Samples/github-terraform-oidc-ci-cd), [`Azure-Samples/azure-devops-terraform-oidc-ci-cd`](https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd))
- ✅ `.github/workflows/` contains only squad automation workflows

**CI/CD Platform Choice:**
- ❌ Not deprecating GitHub Actions
- ❌ Not mandating Azure DevOps
- ✅ Provide both options; users choose based on their platform

---

## Dependencies & Risks

### Dependencies

**External:**
- **AVM Module Availability:** All required AVM modules must be published and stable
- **AVM Module Maturity:** Modules must support features needed for Landing Zone Accelerator
- **Terraform Registry:** Modules must be available on `registry.terraform.io`
- **Bicep Public Registry:** Modules must be available on `br/public:avm/*`
- **Azure API Stability:** Azure Resource Manager APIs must remain stable

**Internal:**
- **Testing Infrastructure:** Need Azure subscriptions for testing
- **CI/CD Setup:** Squad automation workflows must continue to work; legacy deployment workflows being removed
- **Team Bandwidth:** Need dedicated time for migration and testing

### Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| **Pattern module doesn't cover all scenarios** | Medium | High | Validate against all scenarios early (Phase 1); use supplemental resource modules for gaps; maintain individual module mapping as fallback |
| **Pattern module maturity** | Medium | Medium | Pattern modules are relatively new; pin versions, test thoroughly, engage with AVM team, monitor release notes |
| **Pattern module breaking changes** | Medium | High | Pin module versions; test before upgrading; subscribe to AVM release notifications |
| **State migration from custom to pattern module** | High | High | Extensive testing; blue/green approach; document `terraform state mv`; recommend fresh deployments where possible |
| **Pattern module input/output mismatch** | Medium | Medium | Create variable mapping layer; document differences; provide migration examples |
| **AVM resource module not available (supplemental)** | Low | Medium | Document workaround; keep custom module as fallback for that specific resource |
| **AVM resource module missing features (supplemental)** | Medium | Medium | Use inline resources for gaps; submit feature request to AVM |
| **Performance degradation** | Low | Medium | Benchmark before/after; optimize module usage |
| **User adoption resistance** | Medium | Medium | Clear documentation; migration guides; show maintenance burden reduction |
| **Bootstrap complexity** | Medium | Low | Detailed runbooks; automated scripts; example repositories |
| **OIDC federation issues** | Low | Medium | Test in multiple tenants; document troubleshooting; fallback to SPN if needed |
| **Massive maintenance burden reduction** | — | *Positive* | One pattern module replaces dozens of custom modules; Microsoft maintains it; continuous updates |

### Mitigations

**Pattern Module Gaps:**
- Deploy pattern module in isolation first to identify gaps early
- Maintain supplemental AVM resource module mapping for resources not covered
- Keep full individual resource module mapping as fallback reference
- Engage with AVM team to prioritize gaps for inclusion in future pattern module versions
- Document custom implementations for any remaining gaps

**State Migration:**
- Pattern module changes all resource addresses — this is the biggest migration risk
- Recommend fresh deployments for new environments; state migration for existing
- Create comprehensive state migration scripts
- Test migration in non-production environments first
- Provide "blue/green" approach: deploy new alongside old, then switch

**Version Management:**
- Pin all AVM module versions in production
- Test new versions in dev environment before promoting
- Document version compatibility matrix
- Subscribe to AVM release notifications

**User Support:**
- Create detailed migration guides with examples
- Provide comparison tables (old vs. new)
- Set up office hours or Q&A sessions
- Create troubleshooting FAQ

---

## Success Criteria

### Functional

- ✅ Pattern module validated against secure-baseline-multitenant scenario
- ✅ Pattern module validated against ASE v3 scenario
- ✅ Supplemental resource modules deployed for gaps (SQL, Redis, OpenAI, etc.)
- ✅ All custom Terraform modules replaced by pattern module + supplemental modules
- ✅ All custom Bicep modules replaced by pattern module + supplemental modules
- ✅ Spoke deployment succeeds with pattern module (connected to existing ALZ hub)
- ✅ Sample application deploys and runs
- ✅ Private endpoints function correctly
- ✅ DNS resolution works for all private endpoints
- ✅ Front Door routes traffic to App Service
- ✅ Monitoring and diagnostics operational
- ✅ RBAC assignments function correctly
- ✅ GitHub Actions OIDC bootstrap works
- ✅ Azure DevOps OIDC bootstrap works (documented)

### Quality

- ✅ No functionality regressions
- ✅ Deployment time within 10% of baseline
- ✅ Resource costs unchanged or lower
- ✅ Code passes tfsec security scanning
- ✅ Code passes Bicep linting
- ✅ Documentation complete and accurate
- ✅ Migration guide tested and validated

### Non-Functional

- ✅ Repository structure is dramatically cleaner (flat `infra/` layout, spoke-only, pattern module replaces dozens of custom modules)
- ✅ Maintenance burden massively reduced (Microsoft maintains the pattern module)
- ✅ Alignment with Microsoft best practices (AVM pattern module usage)
- ✅ Security improved (OIDC vs. service principals)
- ✅ Developer experience improved (single module call for core landing zone)
- ✅ Discoverability improved (AVM modules are searchable on registries)

### Documentation

- ✅ PRD completed (this document)
- ✅ Migration guide for existing deployments
- ✅ Bootstrap runbooks for GitHub Actions and Azure DevOps
- ✅ AVM module reference guide
- ✅ Breaking changes documented
- ✅ Troubleshooting guide created
- ✅ Architecture docs updated to reference AVM
- ✅ README updated with AVM and bootstrap info

---

## Phasing & Execution

### Recommended Order of Work

> **Note:** The pattern module approach dramatically reduces the timeline. Instead of 7 phases per workstream (replacing 16+ modules one by one), each workstream now has 5 phases centered on validating and configuring the pattern module.

**Stage 1: Planning & Setup (Week 1-2)**
1. ✅ PRD approval (this document)
2. Validate pattern module availability on registries (Terraform Registry and Bicep Public Registry)
3. Set up testing environment (Azure subscriptions, GitHub Actions, Azure DevOps)
4. Spike: Deploy both pattern modules in isolation to validate feature coverage
5. Document gaps between pattern module capabilities and current implementation
6. Create migration tracking (GitHub Projects or Azure Boards)
7. Set up branching strategy (e.g., `feature/pattern-module-migration` branch)

**Stage 2: Terraform Pattern Module Migration (Week 3-6)**
1. Phase 1: Pattern Module Validation — Week 3
2. Phase 2: Configure for Spoke Deployment — Week 3-4
3. Phase 3: Test and Validate — Week 5
4. Phase 4: State Migration and Documentation — Week 5-6
5. Phase 5: Cleanup, Restructure to `infra/terraform/`, Documentation — Week 6

**Stage 3: Bicep Pattern Module Migration (Week 7-10)**
1. Phase 1: Pattern Module Validation — Week 7
2. Phase 2: Configure for Spoke Deployment — Week 7-8
3. Phase 3: Test and Validate — Week 9
4. Phase 4: Cleanup and Documentation — Week 9-10
5. Phase 5: Cleanup, Restructure to `infra/bicep/` — Week 10

**Stage 4: CI/CD Bootstrap (Week 11-12)**
1. Phase 1: Bootstrap Setup — Week 11
2. Phase 2: GitHub Actions Migration — Week 11-12
3. Phase 3: Azure DevOps Setup — Week 12
4. Phase 4: Documentation & Examples — Week 12
5. Phase 5: Legacy Support — Week 12

**Stage 5: Documentation, Structure & Launch (Week 13-14)**
1. Complete migration guide (including hub → ALZ IaC Accelerator migration path)
2. Finalize folder restructure (`scenarios/` → `infra/`)
3. Update architecture documentation (remove hub content, add ALZ IaC Accelerator references)
4. Update README and getting started
5. Create announcement and blog post
6. Release PR and announce

> **Timeline Reduction:** The pattern module approach reduces the overall timeline from ~18 weeks to ~14 weeks, with the most significant savings in the Terraform (6→4 weeks) and Bicep (5→4 weeks) workstreams.

### Parallelization Opportunities

**Can Run in Parallel:**
- Terraform and Bicep pattern module validation can start simultaneously
- Terraform and Bicep migrations can run in parallel with separate teams
- Bootstrap development can start during Stage 2 or 3
- Documentation can be written alongside implementation

**Must Be Sequential:**
- Pattern module validation (Phase 1) must complete before configuration (Phase 2)
- Testing must follow implementation for each phase
- Integration testing must follow all module replacements
- Bootstrap integration requires pattern module migration to be complete (for realistic testing)

### Team Assignments (If Squad-Based)

**Morpheus (Lead/Architect):**
- Overall strategy and coordination
- Pattern module evaluation and gap analysis
- Code reviews for all PRs
- Architecture decisions and trade-offs
- Issue triage and priority setting

**Terraform Specialist:**
- Terraform pattern module validation and configuration
- Supplemental resource module integration
- State migration scripts
- Terraform testing

**Bicep Specialist:**
- Bicep pattern module validation and configuration
- Supplemental resource module integration
- Deployment Stacks validation
- Bicep testing

**DevOps Specialist:**
- CI/CD bootstrap implementation
- Workflow updates
- Pipeline testing

**Documentation Specialist:**
- Migration guides
- Bootstrap runbooks
- Architecture doc updates

---

## Appendix

### AVM Pattern Module References

**Terraform Pattern Module:**
- **Registry:** https://registry.terraform.io/modules/Azure/avm-ptn-app-service-landing-zone/azure
- **GitHub:** https://github.com/Azure/terraform-azure-avm-ptn-app-service-landing-zone
- **Requirements:** Terraform >= 1.9, AzureRM ~> 4.0, azapi ~> 2.4

**Bicep Pattern Module:**
- **Registry:** `br/public:avm/ptn/app-service-lza/hosting-environment` (v0.2)
- **GitHub:** https://github.com/Azure/bicep-registry-modules → `avm/ptn/app-service-lza/hosting-environment`

### AVM Resources

**Official Sites:**
- AVM Portal: https://aka.ms/avm
- AVM GitHub: https://github.com/Azure/Azure-Verified-Modules
- Terraform Modules: https://registry.terraform.io/namespaces/Azure
- Bicep Modules: https://azure.github.io/Azure-Verified-Modules/indexes/bicep/

**Key Documentation:**
- AVM Terraform Quickstart: https://azure.github.io/Azure-Verified-Modules/usage/quickstart/terraform/
- AVM Bicep Quickstart: https://azure.github.io/Azure-Verified-Modules/usage/quickstart/bicep/
- Module Lifecycle: https://azure.github.io/Azure-Verified-Modules/specs/shared/module-lifecycle/

### Bootstrap Reference Repositories

**GitHub Actions + Terraform OIDC:**
- Repo: https://github.com/Azure-Samples/github-terraform-oidc-ci-cd
- Documentation: README in repository

**Azure DevOps + Terraform OIDC:**
- Repo: https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd
- Documentation: README in repository

### Module Version Matrix (Example)

**Pattern Modules:**

| Service | Terraform AVM Module | Version | Bicep AVM Module | Version |
|---------|---------------------|---------|------------------|---------|
| **App Service LZA (Pattern)** | `Azure/avm-ptn-app-service-landing-zone/azure` | latest | `avm/ptn/app-service-lza/hosting-environment` | 0.2 |

**Supplemental Resource Modules:**

| Service | Terraform AVM Module | Version | Bicep AVM Module | Version |
|---------|---------------------|---------|------------------|---------|
| SQL Database | `Azure/avm-res-sql-server/azurerm` | 0.8.x | `avm/res/sql/server` | 0.9.x |
| Redis Cache | `Azure/avm-res-cache-redis/azurerm` | latest | `avm/res/cache/redis` | latest |
| App Configuration | `Azure/avm-res-appconfiguration-configurationstore/azurerm` | latest | `avm/res/app-configuration/configuration-store` | latest |
| Cognitive Services | `Azure/avm-res-cognitiveservices-account/azurerm` | latest | `avm/res/cognitive-services/account` | latest |
| Virtual Machine | `Azure/avm-res-compute-virtualmachine/azurerm` | latest | `avm/res/compute/virtual-machine` | latest |

> **Note:** Azure Firewall is no longer listed as a supplemental module — hub networking is provisioned via the [ALZ IaC Accelerator](https://aka.ms/alz/acc).

**Fallback Resource Modules (if pattern module insufficient):**

| Service | Terraform AVM Module | Version | Bicep AVM Module | Version |
|---------|---------------------|---------|------------------|---------|
| Virtual Network | `Azure/avm-res-network-virtualnetwork/azurerm` | 0.7.x | `avm/res/network/virtual-network` | 0.6.x |
| App Service Plan | `Azure/avm-res-web-serverfarm/azurerm` | 0.3.x | `avm/res/web/serverfarm` | 0.4.x |
| Key Vault | `Azure/avm-res-keyvault-vault/azurerm` | 0.12.x | `avm/res/key-vault/vault` | 0.11.x |

**Note:** Versions are examples. Verify actual versions at migration time.

### Testing Checklist

**Terraform:**
- [ ] `terraform fmt -check` passes
- [ ] `terraform validate` passes
- [ ] `tfsec` passes with no high/critical issues
- [ ] `terraform plan` succeeds
- [ ] `terraform apply` succeeds
- [ ] All outputs populated correctly
- [ ] Resources created in correct resource groups
- [ ] Tags applied correctly
- [ ] Diagnostics sending logs
- [ ] Private endpoints resolvable
- [ ] Sample app deployed and accessible

**Bicep:**
- [ ] `az bicep build` succeeds
- [ ] Bicep linter passes
- [ ] `az deployment sub create --what-if` shows expected changes
- [ ] `az stack sub create` succeeds
- [ ] All outputs populated correctly
- [ ] Resources created in correct resource groups
- [ ] Tags applied correctly
- [ ] Diagnostics sending logs
- [ ] Private endpoints resolvable
- [ ] Sample app deployed and accessible

---

## Changelog

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2024-XX-XX | 1.0 | Initial PRD | Morpheus |
| 2024-XX-XX | 2.0 | **MAJOR UPDATE:** Incorporated AVM pattern modules (`avm-ptn-app-service-landing-zone` for Terraform, `avm/ptn/app-service-lza/hosting-environment` for Bicep) as primary migration strategy. Simplified phasing from 7 phases to 5 per workstream. Reduced timeline from ~18 weeks to ~14 weeks. Added pattern module strategy section, supplemental/fallback module mappings, and updated risks. Individual resource module mappings retained as fallback reference. | Morpheus |
| 2026-XX-XX | 3.0 | **SCOPE SIMPLIFICATION:** (1) Removed hub networking from scope — hub VNet, Azure Firewall, Bastion, and hub-spoke peering are now provisioned via the [ALZ IaC Accelerator](https://aka.ms/alz/acc). This repo is spoke-only. (2) Flattened folder structure from `scenarios/secure-baseline-multitenant/{terraform,bicep}/` to `infra/{terraform,bicep}/`. Removed `scenarios/shared/` entirely. (3) Removed Firewall from supplemental module lists. (4) Updated all workstream phases, validation criteria, and non-goals to reflect spoke-only focus. | Morpheus |
| 2026-XX-XX | 3.1 | **PORTAL & WORKFLOW CLEANUP:** (1) Removed Azure Portal / ARM JSON deployment option from scope — this repo is Terraform and Bicep only. Added "No Azure Portal deployment option" to Non-Goals. (2) Removed references to legacy reusable workflow templates (`.template.terraform.yml`, `.template.bicep.yml`) and composite actions (`tfValidatePlan/`, `tfApply/`). CI/CD handled entirely by OIDC bootstrap repos (`Azure-Samples/github-terraform-oidc-ci-cd`, `Azure-Samples/azure-devops-terraform-oidc-ci-cd`). `.github/workflows/` will only contain squad automation. | Morpheus |

---

## Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Lead/Architect | Morpheus | | |
| Product Owner | Jared Holgate | | |
| Tech Lead (Terraform) | TBD | | |
| Tech Lead (Bicep) | TBD | | |
| DevOps Lead | TBD | | |

---

*End of PRD*
