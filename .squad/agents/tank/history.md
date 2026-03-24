# Project Context

- **Owner:** Jared Holgate
- **Project:** Refactoring the App Service Landing Zone Accelerator to leverage Azure Verified Modules (AVM) for Terraform and Bicep, plus CI/CD bootstrapping with OIDC
- **Stack:** Terraform, Bicep, Azure (App Service, Front Door, Firewall, VNet, Key Vault, SQL, Redis, and more), GitHub Actions, Azure DevOps
- **Repo:** appservice-landing-zone-accelerator
- **Key reference repos:** Azure-Samples/azure-devops-terraform-oidc-ci-cd, Azure-Samples/github-terraform-oidc-ci-cd
- **Created:** 2026-03-24

## Repo Structure

- `scenarios/secure-baseline-multitenant/bicep/` — Bicep implementation with reusable modules
- `scenarios/shared/bicep/` — Shared Bicep modules (network, app-service, databases, etc.)
- `.github/workflows/scenario1.bicep.yml` — Bicep deployment workflow

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2026-03-24: Team Assembly & PRD Complete → Pattern Module Strategy Update

Team hired: Morpheus (Lead), Trinity (Terraform), Tank (Bicep), Switch (DevOps), Niobe (Docs/QA).

**Morpheus completed comprehensive PRD** (docs/PRD.md v1.0):
- 3 workstreams: Terraform AVM (6 weeks), Bicep AVM (5 weeks), CI/CD Bootstrap (2 weeks)
- 16 Terraform + 24 Bicep module mappings
- 10 architectural decisions documented
- Risk assessment and phased execution plan

**PATTERN MODULE DISCOVERY (v2.0):** AVM now offers `br/public:avm/ptn/app-service-lza/hosting-environment` (v0.2) pattern module on Bicep Public Registry that consolidates 22 Bicep custom modules into a single module call. This fundamentally changes Tank's work:

**Tank's Updated Responsibilities:**
- Primary: Deploy AVM pattern module (`br/public:avm/ptn/app-service-lza/hosting-environment`) in place of 24 custom modules
- Supplemental: Individual AVM resource modules for: Firewall, SQL, Redis, OpenAI, App Config
- Full module mapping retained as reference/fallback
- Pattern module maturity consideration (v0.2 is relatively new)

**Updated Timeline & Phases:**
- 5 weeks reduced to ~4 weeks (pattern module reduces module-by-module work)
- 7-phase rollout reduced to 5 phases (pattern module validates as complete unit)

**Decisions Affecting Bicep Work:**
- Decision 1 (AVM-First) — Updated: Now pattern-module-first strategy
- Decision 4 (Keep Scenario Wrappers) — Updated: Most wrappers become unnecessary; pattern module handles composition
- Decision 11 (NEW): Adopt AVM Pattern Modules as Primary Strategy
- Decision 12 (NEW): Hub Networking Deferred to ALZ IaC Accelerator — Simplifies Tank's work (spoke-only model)
- Decision 13 (NEW): Folder Structure Flattened to infra/ — All paths reference `infra/bicep/` and `infra/modules/`
- Decision 14 (NEW): Portal & ARM Templates Out of Scope — Only Terraform/Bicep deployment paths
- Decision 15 (NEW): CI/CD Consolidation (OIDC-Only) — No legacy workflows; OIDC bootstrap required
- State Migration: Deployment Stack addresses change; pattern module scope includes entire LZA; simplified by hub removal
- See .squad/decisions.md for full decision log.

### 2026-03-24: Initial infra/bicep/ Implementation Created

**Created `infra/bicep/` with three files:**

1. **`main.bicep`** — Subscription-scoped deployment calling `br/public:avm/ptn/app-service-lza/hosting-environment:0.2.0`. Configures spoke-only model with Front Door ingress, Key Vault (RBAC, private), App Insights (private, Entra-only), and optional hub peering via `hubVnetResourceId` / `firewallInternalIp` parameters.

2. **`main.bicepparam`** — Example parameter file using the Bicep native `.bicepparam` format (`using 'main.bicep'`). Includes placeholder for Log Analytics workspace and commented-out hub integration params.

3. **`README.md`** — Usage guide covering `az deployment sub create`, `az stack sub create`, hub connection via ALZ IaC Accelerator, prerequisites, and resource inventory.

**Key findings:**
- PRD referenced version `0.2` but the actual registry tag is `0.2.0` (semver). Fixed before commit.
- Pattern module is `targetScope = 'subscription'` — creates its own resource group.
- Module exposes typed config objects (`spokeNetworkConfigType`, `servicePlanConfigType`, etc.) imported from `shared.types.bicep`.
- Null-coalescing (`??`) is used heavily inside the module so most config properties are optional with sensible defaults.
- Module creates managed identity, private endpoints, private DNS zones, NSGs, and route tables automatically — no need for supplemental modules for core spoke resources.
- Front Door auto-approver managed identity is created by the module for private endpoint approval.

### 2026-03-24: Created 9 ALZ Example .bicepparam Files

**Expanded `main.bicep` to support all hosting models:**
- Added `deployAseV3` (bool) for ASE v3 deployments
- Added `appServiceKind` (`app`, `app,linux`, `app,container,windows`, `app,linux,container`) for OS+container selection
- Added `containerImageName` / `containerRegistryUrl` for container registry integration
- Added `appServicePlanCustomMode` for Windows Managed Instance (custom-mode ASP with RDP)
- Added `storageAccountRequired` for managed instance storage needs
- Updated module call to pass `kind`, `container`, `isCustomMode`, and `storageAccountRequired` through to the pattern module

**Created `infra/bicep/examples/` with 9 ready-to-deploy parameter files:**
1. `managed-instance.bicepparam` — Windows Managed Instance (custom mode, storage)
2. `ase-windows-app.bicepparam` — ASE v3 + Windows code-based
3. `ase-windows-container.bicepparam` — ASE v3 + Windows container + ACR
4. `ase-linux-app.bicepparam` — ASE v3 + Linux code-based
5. `ase-linux-container.bicepparam` — ASE v3 + Linux container + ACR
6. `asp-windows-app.bicepparam` — Multitenant ASP + Windows code-based
7. `asp-windows-container.bicepparam` — Multitenant ASP + Windows container + ACR
8. `asp-linux-app.bicepparam` — Multitenant ASP + Linux code-based
9. `asp-linux-container.bicepparam` — Multitenant ASP + Linux container + ACR

All examples include ALZ Platform Landing Zone integration: hub VNet peering, firewall egress (10.0.0.4), private DNS, diagnostic settings to central Log Analytics, and compliant tags. Each uses a unique spoke CIDR (10.241-249.0.0/20) for multi-scenario deployments. ASE scenarios use I1v2 SKU with /24 subnets; multitenant scenarios use P1V3 with /26 subnets.

**Key findings:**
- Pattern module's `appServiceConfig.kind` is the critical discriminator: `app` vs `app,linux` vs `app,container,windows` vs `app,linux,container`
- ASE v3 requires at least a /24 subnet (default /26 is too small)
- `servicePlanConfig.isCustomMode` + `storageAccountRequired` enable the managed instance pattern
- Container image is set via `appServiceConfig.container.imageName` — the module auto-constructs `DOCKER|<imageName>` for linuxFxVersion/windowsFxVersion
- Kept `main.bicepparam` as a minimal standalone default (no hub) with pointer to `examples/` for ALZ scenarios

### Cross-Agent Context: Trinity's Terraform Parity (2026-03-24)

**Trinity (Terraform) completed identical 9-scenario coverage:**
- 9 `.tfvars` files matching Tank's Bicep scenario names (managed-instance, ase-windows-app, ase-windows-container, ase-linux-app, ase-linux-container, asp-windows-app, asp-windows-container, asp-linux-app, asp-linux-container)
- Pattern module `Azure/avm-ptn-app-service-landing-zone/azure:0.1.0` used (Terraform registry equivalent of Tank's Bicep pattern module)
- Examples README guides users on all scenarios
- `terraform validate` passes successfully

**Parity achieved:** Both Terraform and Bicep IaC paths now offer identical scenario coverage with mirrored naming. Users can choose IaC tool without losing scenario options.

### Resource Group Module Added — Explicit RG Creation via AVM

**Changed `main.bicep` to explicitly create the spoke resource group** using `br/public:avm/res/resources/resource-group:0.4.0` before calling the pattern module. Previously the pattern module created the RG internally with an auto-generated name. Now:

- Added `resourceGroupName` parameter (defaults to `rg-${workloadName}-${environmentName}`) — users provide a name, not an existing ID.
- AVM resource group module creates the RG at subscription scope.
- The same `resourceGroupName` is passed through to `spokeNetworkConfig.resourceGroupName` so the pattern module targets the same RG (idempotent).
- `dependsOn` ensures the RG exists before the pattern module runs.
- Outputs now include both `spokeResourceGroupName` and `spokeResourceGroupResourceId` from our explicit RG module.
- Updated `main.bicepparam` and all 9 example `.bicepparam` files with explicit `resourceGroupName` values matching the workload naming convention.
- README updated to list `resourceGroupName` as a key parameter.

**Key finding:** The pattern module (`hosting-environment:0.2.0`) internally uses `br/public:avm/res/resources/resource-group:0.4.3` and accepts `spokeNetworkConfig.resourceGroupName`. Creating the RG externally first is safe because Azure resource group creation is idempotent — the pattern module's internal RG call simply updates/no-ops on the existing RG.

