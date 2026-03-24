# Project Context

- **Owner:** Jared Holgate
- **Project:** Refactoring the App Service Landing Zone Accelerator to leverage Azure Verified Modules (AVM) for Terraform and Bicep, plus CI/CD bootstrapping with OIDC
- **Stack:** Terraform, Bicep, Azure (App Service, Front Door, Firewall, VNet, Key Vault, SQL, Redis, and more), GitHub Actions, Azure DevOps
- **Repo:** appservice-landing-zone-accelerator
- **Key reference repos:** Azure-Samples/azure-devops-terraform-oidc-ci-cd, Azure-Samples/github-terraform-oidc-ci-cd
- **Created:** 2026-03-24

## Repo Structure

- `scenarios/secure-baseline-multitenant/terraform/` — Terraform implementation (hub/spoke split)
- `scenarios/shared/terraform-modules/` — Shared Terraform modules (front-door, firewall, app-service, sql, redis, etc.)
- `.github/workflows/scenario1.terraform.yml` — Terraform deployment workflow
- `.github/actions/templates/` — Reusable Terraform CI/CD actions (validate/plan, apply)

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2026-03-24: Team Assembly & PRD Complete → Pattern Module Strategy Update

Team hired: Morpheus (Lead), Trinity (Terraform), Tank (Bicep), Switch (DevOps), Niobe (Docs/QA).

**Morpheus completed comprehensive PRD** (docs/PRD.md v1.0):
- 3 workstreams: Terraform AVM (6 weeks), Bicep AVM (5 weeks), CI/CD Bootstrap (2 weeks)
- 16 Terraform + 24 Bicep module mappings
- 10 architectural decisions documented
- Risk assessment and phased execution plan

**PATTERN MODULE DISCOVERY (v2.0):** AVM now offers `Azure/avm-ptn-app-service-landing-zone/azure` pattern module (registry.terraform.io) that consolidates 12 Terraform custom modules into a single module call. This fundamentally changes Trinity's work:

**Trinity's Updated Responsibilities:**
- Primary: Deploy AVM pattern module (`Azure/avm-ptn-app-service-landing-zone/azure`) in place of 16 custom modules
- Supplemental: Individual AVM resource modules for: Firewall, SQL, Redis, OpenAI, App Config, VM (jump host)
- Full module mapping retained as reference/fallback

**Updated Timeline & Phases:**
- 6 weeks reduced to ~5 weeks (pattern module reduces module-by-module work)
- 7-phase rollout reduced to 5 phases (pattern module validates as complete unit)

**Decisions Affecting Terraform Work:**
- Decision 1 (AVM-First) — Updated: Now pattern-module-first strategy
- Decision 11 (NEW): Adopt AVM Pattern Modules as Primary Strategy
- Decision 12 (NEW): Hub Networking Deferred to ALZ IaC Accelerator — Simplifies Trinity's work (spoke-only model)
- Decision 13 (NEW): Folder Structure Flattened to infra/ — All paths reference `infra/terraform/` and `infra/modules/`
- Decision 14 (NEW): Portal & ARM Templates Out of Scope — Only Terraform/Bicep deployment paths
- Decision 15 (NEW): CI/CD Consolidation (OIDC-Only) — No legacy workflows; OIDC bootstrap required
- State Migration: `terraform state mv` scripts needed for address changes (pattern module state structure different); simplified by hub removal
- See .squad/decisions.md for full decision log.

### 2026-03-24: Initial infra/terraform/ Implementation Created

Created the initial `infra/terraform/` directory with the AVM pattern module integration:

**Files created:**
- `terraform.tf` — Provider config (AzureRM ~> 4.0, AzAPI ~> 2.4, Terraform >= 1.9 < 2.0)
- `main.tf` — Single module call to `Azure/avm-ptn-app-service-landing-zone/azure` v0.1.0; configures spoke-only deployment with optional ALZ hub peering
- `variables.tf` — Exposes key inputs: location, resource_group_id, app service plan settings, web_apps map, networking CIDRs, feature toggles (Front Door, Key Vault, App Insights, private DNS), ALZ hub integration (hub VNet ID, firewall IP, route table), environment, tags
- `outputs.tf` — Exposes: app service plan ID, web app map + hostnames, VNet ID/name, Front Door, Key Vault ID/name, App Insights connection string, Log Analytics workspace ID, resource group name
- `terraform.tfvars.example` — Example values for all variables
- `README.md` — Usage instructions, prerequisites, ALZ hub integration guide, CI/CD reference

**Key design decisions:**
- Module pinned to v0.1.0 (first published release on registry)
- `parent_id` (resource group ID) is required — module does not create the resource group
- Hub peering is derived from variables: `hub_virtual_network_id != null` enables peering automatically
- `key_vault_enabled` defaults to `true` (overriding module default of `false`) because LZA should include secrets management
- `front_door_enabled` defaults to `true` (matches module default) for WAF-protected ingress
- Validated with `terraform init -backend=false && terraform validate` — passes clean

**Module interface notes (v0.1.0):**
- Required inputs: `location`, `parent_id`
- Variable files are split across ~19 files in the upstream repo (variables.tf, variables.virtual_network.tf, etc.)
- App Service Plan defaults: Linux / P1v3
- Virtual network defaults: 10.0.0.0/16 with /24 subnets
- ALZ variables prefixed with `alz_platform_landing_zone_*`
- Web apps configured via `web_apps` map (any type — complex object)

### 2026-03-24: Created 9 Example .tfvars Files + Removed Legacy Example

Created `infra/terraform/examples/` with 9 complete, ALZ-integrated `.tfvars` files covering all deployment scenarios:

**Files created (9 tfvars + README):**
- `managed-instance.tfvars` — WindowsManagedInstance, P1v4, .NET code-based
- `ase-windows-app.tfvars` — ASE v3, Windows, I1v2, .NET code-based
- `ase-windows-container.tfvars` — ASE v3, WindowsContainer, I1v2, Docker from ACR
- `ase-linux-app.tfvars` — ASE v3, Linux, I1v2, .NET code-based
- `ase-linux-container.tfvars` — ASE v3, Linux, I1v2, Docker from ACR
- `asp-windows-app.tfvars` — App Service Plan, Windows, P1v3, .NET code-based
- `asp-windows-container.tfvars` — App Service Plan, WindowsContainer, P1v3, Docker from ACR
- `asp-linux-app.tfvars` — App Service Plan, Linux, P1v3, .NET code-based
- `asp-linux-container.tfvars` — App Service Plan, Linux, P1v3, Docker from ACR
- `README.md` — Usage guide with scenario selection matrix

**Variables added to support all scenarios:**
- `app_service_environment_enabled` (bool, default false) — enables ASE v3
- `app_service_environment_subnet_address_prefix` (string, default "10.0.2.0/24") — ASE subnet
- `container_registry_enabled` (bool, default false) — enables Azure Container Registry

**main.tf updated:** Wired `app_service_environment_enabled`, `app_service_environment_subnet_address_prefix`, and `container_registry_enabled` through to the pattern module.

**Removed:** `terraform.tfvars.example` — superseded by `examples/` directory.

**Key learnings:**
- Upstream module uses `v8.0` prefix for Windows dotnet_version but `8.0` for Linux (no `v` prefix)
- ASE scenarios auto-adjust SKU to Isolated tier if non-Isolated SKU is specified
- Container scenarios use `application_stack.docker` block with `docker_image_name` and `docker_registry_url`
- Each example uses unique /16 address spaces (10.1-10.9) to avoid conflicts in multi-scenario deployments
- All examples include ALZ hub peering, firewall routing, and standard tagging

### Cross-Agent Context: Tank's Bicep Parity (2026-03-24)

**Tank (Bicep) completed identical 9-scenario coverage:**
- 9 `.bicepparam` files matching Terraform scenario names (managed-instance, ase-windows-app, ase-windows-container, ase-linux-app, ase-linux-container, asp-windows-app, asp-windows-container, asp-linux-app, asp-linux-container)
- Pattern module `br/public:avm/ptn/app-service-lza/hosting-environment:0.2.0` used (Bicep registry equivalent of Trinity's Terraform pattern module)
- Examples README guides users on all scenarios
- `az bicep build` validates successfully

**Parity achieved:** Both Terraform and Bicep IaC paths now offer identical scenario coverage with mirrored naming. Users can choose IaC tool without losing scenario options.

### Resource Group Creation via AVM Module

Replaced the `resource_group_id` (existing RG ID) input with `resource_group_name` (name to create). The module now creates the resource group automatically using `Azure/avm-res-resources-resourcegroup/azurerm` v0.2.2, then passes the created RG's `resource_id` to the pattern module's `parent_id`. This simplifies the user experience — users only provide a name and location, no need to pre-create resource groups.

**Changes made:**
- `main.tf` — Added `module "resource_group"` block before the pattern module; wired `module.resource_group.resource_id` to `parent_id`
- `variables.tf` — Replaced `resource_group_id` (string, validated as Azure resource ID) with `resource_group_name` (string, validated as Azure RG name format)
- `outputs.tf` — Added `resource_group_id` output from the new module; updated `resource_group_name` to source from `module.resource_group.name`
- All 9 example `.tfvars` files updated: replaced `resource_group_id = "/subscriptions/.../resourceGroups/rg-..."` with `resource_group_name = "rg-..."`
- `terraform init -backend=false && terraform validate` passes clean

**Key learning:** The AVM resource group module (`Azure/avm-res-resources-resourcegroup/azurerm`) v0.2.2 requires only `name` and `location` as inputs, and outputs `resource_id`, `name`, `resource`, and `location`. It also supports `tags`, `lock`, `role_assignments`, and `enable_telemetry`.

### ALZ Platform Landing Zone Variable Audit & Gap Fix

Audited all 11 `alz_platform_landing_zone_*` variables in the upstream AVM pattern module (`Azure/terraform-azure-avm-ptn-app-service-landing-zone`) against our wrapper. Found 3 meaningful gaps and fixed them:

**Variables added to `variables.tf` + wired in `main.tf`:**
- `alz_diagnostic_settings_mode_enabled` → `alz_platform_landing_zone_diagnostic_settings_mode_enabled` — When true, module skips creating diagnostic settings (relies on ALZ DINE policy)
- `alz_private_dns_zone_mode_enabled` → `alz_platform_landing_zone_private_dns_zone_mode_enabled` — When true, module skips creating private DNS zones (relies on ALZ policy)
- `hub_route_table_resource_id` → `alz_platform_landing_zone_route_table_resource_id` — Use an existing route table from the PLZ instead of creating one

**Variables intentionally NOT exposed** (naming overrides rarely needed by end users):
- `alz_platform_landing_zone_peer_from_hub_name` — peering name customization
- `alz_platform_landing_zone_peer_to_hub_name` — peering name customization
- `alz_platform_landing_zone_route_table_name` — route table name customization

**All 9 example .tfvars updated:**
- Added PREREQUISITE comment block to each file header
- Renamed "ALZ Hub Integration" section to "ALZ Platform Landing Zone Integration" with guidance comments
- Added `alz_diagnostic_settings_mode_enabled = false` and `alz_private_dns_zone_mode_enabled = false` with explanatory comments
- Added commented-out `hub_route_table_resource_id` placeholder

**README.md updated:**
- Added comprehensive Prerequisites section explaining PLZ dependency, required values, and where to find them
- Updated ALZ integration section to document new variables
- `terraform validate` passes clean

**Key learning:** The upstream module's `alz_platform_landing_zone_diagnostic_settings_mode_enabled` and `alz_platform_landing_zone_private_dns_zone_mode_enabled` are critical for real ALZ deployments — without them the module creates duplicate diagnostic settings and private DNS zones that conflict with ALZ centralized policy. The `route_table_resource_id` is important when the ALZ platform provides managed route tables.

