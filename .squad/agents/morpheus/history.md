# Project Context

- **Owner:** Jared Holgate
- **Project:** Refactoring the App Service Landing Zone Accelerator to leverage Azure Verified Modules (AVM) for Terraform and Bicep, plus CI/CD bootstrapping with OIDC
- **Stack:** Terraform, Bicep, Azure (App Service, Front Door, Firewall, VNet, Key Vault, SQL, Redis, and more), GitHub Actions, Azure DevOps
- **Repo:** appservice-landing-zone-accelerator
- **Key reference repos:** Azure-Samples/azure-devops-terraform-oidc-ci-cd, Azure-Samples/github-terraform-oidc-ci-cd
- **Created:** 2026-03-24

## Repo Structure

- `infra/terraform/` — Terraform implementation using AVM pattern modules (hub/spoke)
- `infra/bicep/` — Bicep implementation using AVM modules
- `bootstrap/` — OIDC CI/CD bootstrap for GitHub Actions and Azure DevOps
- `sampleapp/` — ASP.NET Core sample workload
- `docs/` — Hugo documentation site (hugo.toml, content/, layouts/, themes/)
- `deploy.ps1` — Interactive deployment script (bootstrap or local deploy)

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2024-03-24: Repository Structure & Module Inventory

**Terraform Implementation:**
- Hub/spoke architecture in `scenarios/secure-baseline-multitenant/terraform/`
- 16 custom modules in `scenarios/shared/terraform-modules/`
- Key modules: network, firewall, bastion, app-service (with child modules), key-vault, sql-database, redis, frontdoor, openai, windows-vm
- Provider versions: AzureRM ~>4.5.0, AzureCAF >=1.2.23, Terraform >=1.3
- State managed via AzureRM backend with storage account
- CI/CD: Reusable workflow pattern with OIDC, tfsec scanning, artifact-based plan/apply

**Bicep Implementation:**
- Hub/spoke architecture in `scenarios/secure-baseline-multitenant/bicep/`
- Shared modules in `scenarios/shared/bicep/` covering networking, app services, databases, storage, cognitive services
- Scenario-specific wrappers in `scenarios/secure-baseline-multitenant/bicep/modules/`
- Deployment uses Azure Deployment Stacks at subscription level
- CI/CD: Reusable workflow pattern with OIDC, bicep build validation

**Key Architectural Patterns:**
- Hub provides: VNet, Firewall (with egress rules), Bastion, Log Analytics
- Spoke provides: VNet, App Service/ASEv3, Front Door, Key Vault, SQL, Redis, OpenAI (optional), App Config (optional), Jump Host (optional)
- Hub→Spoke peering with UDR for forced tunneling through firewall
- Private endpoints + private DNS zones for all PaaS services
- Managed identities + RBAC (no passwords/keys in code)

**Azure Services Inventory:**
- Compute: App Service, ASE v3, Virtual Machines
- Networking: VNet, Firewall, Front Door, Application Gateway (implicit), Bastion, Private Endpoint, Private DNS Zone, NSG, UDR
- Data: SQL Database, Redis Cache, Storage Account
- App Platform: App Configuration, Key Vault
- AI: OpenAI (Cognitive Services)
- Monitoring: Log Analytics, Application Insights, Monitor Diagnostics

**File Paths to Remember:**
- Terraform entry: `scenarios/secure-baseline-multitenant/terraform/main.tf`
- Terraform hub: `scenarios/secure-baseline-multitenant/terraform/hub/`
- Terraform spoke: `scenarios/secure-baseline-multitenant/terraform/spoke/`
- Bicep entry: `scenarios/secure-baseline-multitenant/bicep/main.bicep`
- Workflows: `.github/workflows/scenario1.terraform.yml`, `.github/workflows/scenario1.bicep.yml`
- Composite actions: `.github/actions/templates/tfValidatePlan/`, `.github/actions/templates/tfApply/`

### 2024-03-24: Azure Verified Modules (AVM) Research

**AVM Overview:**
- Microsoft-official IaC modules for Terraform and Bicep
- Well-Architected Framework aligned
- Published to Terraform Registry (`Azure/avm-res-*`) and Bicep Public Registry (`br/public:avm/*`)
- Three types: Resource (RES), Pattern (PNT), Utility (UTL)
- Maintained by Microsoft, continuously updated

**AVM Module Availability (2024):**
- **Terraform:** 100+ resource modules on registry.terraform.io/namespaces/Azure
- **Bicep:** 170+ resource modules, 40+ pattern modules on Bicep Public Registry
- Coverage for all services used in this repo: VNet, Firewall, Bastion, App Service, Key Vault, SQL, Redis, Front Door, OpenAI, VM, etc.

**Key AVM Modules for This Project:**
- Networking: `avm-res-network-virtualnetwork`, `avm-res-network-azurefirewall`, `avm-res-network-bastionhost`, `avm-res-network-privatednszone`, `avm-res-network-privateendpoint`
- App Platform: `avm-res-web-serverfarm`, `avm-res-web-site` (includes ASE), `avm-res-keyvault-vault`, `avm-res-appconfiguration-configurationstore`
- Data: `avm-res-sql-server`, `avm-res-cache-redis`, `avm-res-storage-storageaccount`
- AI: `avm-res-cognitiveservices-account`
- Front Door: `avm-res-cdn-profile`
- Compute: `avm-res-compute-virtualmachine`

**AVM Patterns:**
- Hub networking: `avm/ptn/network/hub-networking`
- App Service LZA: `avm/ptn/app-service-lza/hosting-environment`
- Pattern modules can accelerate migration

**User Preference:**
- Jared Holgate (owner) prefers comprehensive planning before execution
- Wants detailed PRD with specific module mappings, file paths, and phasing

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2026-03-24: PRD v2.0 — Pattern Module Strategy

**Strategic Shift:** Discovered that AVM **pattern modules** exist for the App Service Landing Zone:
- **Terraform:** `Azure/avm-ptn-app-service-landing-zone/azure` (registry.terraform.io)
- **Bicep:** `br/public:avm/ptn/app-service-lza/hosting-environment` (v0.2)

These pattern modules deploy the ENTIRE App Service Landing Zone in a single module call — VNet, subnets, peering, App Service, Front Door/App GW, Key Vault, Bastion, Storage, ACR, App Insights, Log Analytics, private endpoints, DNS, RBAC, managed identities, diagnostics.

**Impact on PRD:**
- Replaces 12 Terraform custom modules and 22 Bicep custom modules with ONE module call each
- Phasing reduced from 7 phases to 5 per workstream
- Timeline reduced from ~18 weeks to ~14 weeks
- Repo's role shifts from "infrastructure code" to "configuration + supplements + docs"
- Individual AVM resource modules still needed for: Firewall, SQL, Redis, OpenAI, App Configuration, VM (jump host)
- Full individual resource module mapping retained as fallback reference

**Key Risks Added:**
- Pattern module maturity (relatively new)
- State migration complexity (all resource addresses change)
- Pattern module may not cover all edge cases

**Key Benefits:**
- Massive maintenance burden reduction (Microsoft maintains the pattern module)
- Single module call replaces dozens of custom modules
- Continuous updates from Microsoft
- Well-Architected Framework aligned by default

**Decision 11 (approved):** "Adopt AVM Pattern Modules as Primary Migration Strategy"
- Logged to `.squad/decisions.md`
- Updates Decisions 1, 4, 8


**Team Hired:**
- Morpheus (Lead/Architect) — Overall vision, AVM strategy
- Trinity (Terraform Specialist) — Terraform AVM migration
- Tank (Bicep Specialist) — Bicep AVM migration
- Switch (DevOps/CI-CD) — Bootstrap and CI/CD automation
- Niobe (Documentation/QA) — Migration guides, testing, documentation

**PRD Created:** docs/PRD.md (49KB)
- 3 workstreams: Terraform AVM (6 weeks), Bicep AVM (5 weeks), CI/CD Bootstrap (2 weeks)
- 16 Terraform module mappings identified
- 24 Bicep module mappings identified
- 7-phase execution plan per workstream
- Risk assessment and mitigation strategies
- Success criteria: Zero functionality regression, all scenarios deploy successfully

**10 Key Decisions Documented:**
1. AVM-First Strategy (replace custom modules)
2. Terraform-First Migration (then Bicep in parallel)
3. CI/CD Bootstrap Integration (GitHub Actions + Azure DevOps)
4. Keep Scenario-Specific Wrappers (refactor, don't remove)
5. Pin AVM Module Versions (controlled updates)
6. State Migration Strategy (terraform state mv + blue/green)
7. Sample App Unchanged (no scope creep)
8. Phased Rollout (Foundation → Integration)
9. No Platform Lock-In (GitHub + Azure DevOps parity)
10. Documentation Over Code Comments (external docs prioritized)

**Orchestration Log:** .squad/orchestration-log/2026-03-24T11-13-morpheus.md
**Session Log:** .squad/log/2026-03-24-team-init-prd.md
**Decisions Merged:** .squad/decisions.md (all 10 decisions now canonical)

**Next Steps:** Stakeholder review, approval, create tracking project, begin Stage 1 execution.

### 2026-03-24: PRD v2.0 — Pattern Module Strategy

**Strategic Shift:** Discovered that AVM **pattern modules** exist for the App Service Landing Zone:
- **Terraform:** `Azure/avm-ptn-app-service-landing-zone/azure` (registry.terraform.io)
- **Bicep:** `br/public:avm/ptn/app-service-lza/hosting-environment` (v0.2)

These pattern modules deploy the ENTIRE App Service Landing Zone in a single module call — VNet, subnets, peering, App Service, Front Door/App GW, Key Vault, Bastion, Storage, ACR, App Insights, Log Analytics, private endpoints, DNS, RBAC, managed identities, diagnostics.

**Impact on PRD:**
- Replaces 12 Terraform custom modules and 22 Bicep custom modules with ONE module call each
- Phasing reduced from 7 phases to 5 per workstream
- Timeline reduced from ~18 weeks to ~14 weeks
- Repo's role shifts from "infrastructure code" to "configuration + supplements + docs"
- Individual AVM resource modules still needed for: Firewall, SQL, Redis, OpenAI, App Configuration, VM (jump host)
- Full individual resource module mapping retained as fallback reference

**Key Risks Added:**
- Pattern module maturity (relatively new)
- State migration complexity (all resource addresses change)
- Pattern module may not cover all edge cases

**Key Benefits:**
- Massive maintenance burden reduction (Microsoft maintains the pattern module)
- Single module call replaces dozens of custom modules
- Continuous updates from Microsoft
- Well-Architected Framework aligned by default

### 2026-XX-XX: PRD v3.0 — Scope Simplification (Spoke-Only + Flat Structure)

**Two structural changes directed by Jared Holgate:**

1. **Hub networking removed from scope.** This repo no longer deploys Azure Firewall, Bastion, hub VNet, or hub-spoke peering. Users provision hub infrastructure via the [ALZ IaC Accelerator](https://aka.ms/alz/acc) and connect their spoke using the pattern module's hub integration parameters (`hub_virtual_network_id`, `route_table_id`, etc.). Azure Firewall removed from supplemental module lists.

2. **Folder structure flattened.** `scenarios/secure-baseline-multitenant/{terraform,bicep}/` to `infra/{terraform,bicep}/`. `scenarios/shared/` removed entirely (already being replaced by AVM pattern modules). `sampleapp/` and `docs/` unchanged.

**Impact on PRD:**
- PRD updated to v3.0 with 25+ surgical edits across all major sections
- Executive Summary: added spoke-only focus and ALZ reference
- Target State: new flat `infra/` structure, spoke-only vision
- Both workstreams: removed hub phases, updated paths from `scenarios/` to `infra/`
- Non-Goals: hub networking added explicitly as out-of-scope
- Supplemental modules: Firewall removed from both Terraform and Bicep lists
- Phasing: updated stage descriptions for restructuring steps

**Decisions logged:** 12 (Remove Hub from Scope) and 13 (Flatten Repository Structure) in `.squad/decisions/inbox/morpheus-scope-simplification.md`

### 2026-XX-XX: PRD v3.1 — Portal/ARM Removal & Workflow Cleanup

**Two surgical scope changes to PRD:**

1. **Azure Portal / ARM deployment removed from scope.** No `azure-resource-manager/` folder, no ARM JSON templates, no "Deploy to Azure" buttons. This repo is Terraform and Bicep only. Added to Non-Goals.

2. **Legacy deployment workflows removed.** The reusable workflow templates (`.template.terraform.yml`, `.template.bicep.yml`), deployment workflows (`scenario1.terraform.yml`, `scenario1.bicep.yml`), and composite actions (`tfValidatePlan/`, `tfApply/`) are being removed. CI/CD is handled entirely by the two OIDC bootstrap repos (`Azure-Samples/github-terraform-oidc-ci-cd`, `Azure-Samples/azure-devops-terraform-oidc-ci-cd`). The `.github/workflows/` folder will only contain squad automation workflows.

**PRD sections updated:**
- Current State: repo structure tree annotated with ⚠️ removal markers
- Current CI/CD Pattern (Terraform & Bicep): marked as being removed with bootstrap repo links
- Target State: `.github/` simplified to squad automation only
- Success Metrics: updated to reflect workflow removal and bootstrap-only CI/CD
- Workstream 1 Phase 4: renamed, workflow removal task added
- Workstream 2 Phase 4: renamed, workflow removal task added
- Workstream 3 Phase 2: legacy workflow removal tasks replace template update tasks
- Workstream 3 Integration Points: "Workflow Updates" replaced with "Workflow Cleanup"
- Non-Goals: added Portal/ARM and custom deployment workflows sections
- Dependencies: CI/CD internal dependency updated
- Timeline: Phase 4 names updated
- Changelog: v3.1 entry added

**Decisions logged:** 14 (Remove Portal/ARM) and 15 (Remove Legacy Workflows) in `.squad/decisions/inbox/morpheus-portal-workflows.md`

### 2026-XX-XX: Hugo Documentation Site Restructuring

**What was done:**
- Removed legacy `docs/Design-Areas/` (6 markdown files) and `docs/App-Service-LZA.vsdx`
- Created full Hugo static site in `docs/` matching `Azure/Azure-Landing-Zones` pattern:
  - `hugo.toml` with hugo-geekdoc theme config, adapted for this repo
  - Content sections: home, getting-started, terraform, bicep, bootstrap, architecture, examples
  - Bootstrap content migrated from `bootstrap/` READMEs into Hugo content pages (github-actions.md, azure-devops.md)
  - Architecture images preserved in `docs/static/img/`
  - Empty dirs with `.gitkeep` for themes, layouts, assets, data (Hugo standard structure)
- Bootstrap READMEs slimmed to thin pointers redirecting to Hugo docs site
- Root `README.md` simplified from 200+ lines to ~20-line landing page with docs site links
- All Hugo content pages use geekdoc front matter (`title`, `weight`, `geekdocCollapseSection`)

**Key patterns established:**
- Documentation site URL: `https://azure.github.io/appservice-landing-zone-accelerator`
- Theme: hugo-geekdoc (installed via git submodule — `git submodule add https://github.com/thegeeklab/hugo-geekdoc.git docs/themes/hugo-geekdoc`)
- Content in `docs/content/` with `_index.md` per section
- Images in `docs/static/img/`
- hugo.toml includes LLM-friendly TXT output format

**Follow-up needed:**
- GitHub Pages deployment workflow (GitHub Actions to build and deploy Hugo site)
- Install hugo-geekdoc theme as git submodule before first build
- Content expansion: add more detailed architecture guidance, migration guides

**Decisions logged:** 16 (Hugo Documentation Site) and 17 (Simplify Root README) in `.squad/decisions/inbox/morpheus-hugo-docs.md`

### 2026-XX-XX: Hugo Site Rendering Fix — Aligned with Azure/Azure-Landing-Zones Reference

**Problem:** Hugo site built with 3 warnings ("found no layout file for 'txt'") and was missing header navigation links, LLMs-friendly output, and useful shortcodes.

**Root cause:** When the Hugo site was initially scaffolded, `layouts/`, `data/`, and `assets/` were created with `.gitkeep` placeholders instead of actual layout templates and data files. The `hugo.toml` defined a TXT output format (for `llms.txt`) but no templates existed to render it. Additionally, `description` was placed at the top level of `hugo.toml` instead of under `[params]`, making it inaccessible to templates.

**Fixes applied (compared against `Azure/Azure-Landing-Zones` reference repo):**
1. **TXT layout templates** — Added `layouts/_default/index.txt`, `list.txt`, `single.txt` and `layouts/partials/llms-section-tree.txt` to generate `llms.txt` for every page (LLM-friendly plain text output)
2. **Header navigation** — Added `data/menu/main.yaml` (Home link) and `data/menu/extra.yaml` (Home, GitHub, Issue links in header bar)
3. **Shortcodes** — Added `layouts/shortcodes/expand.html`, `include.html`, `csv-table.html` for rich content authoring
4. **hugo.toml** — Moved `description` under `[params]` so templates can access it via `.Site.Params.description`
5. **Removed `.gitkeep` files** — Replaced empty placeholders in `data/`, `layouts/`, `assets/` with real content

**Result:** Clean build with zero warnings, 31 pages generated (up from 22), `llms.txt` output on every page, header nav with GitHub/Issue links.

**Key lesson:** When setting up hugo-geekdoc, don't just create the directory structure — you need:
- TXT templates if `outputFormats.TXT` is defined in `hugo.toml`
- `data/menu/extra.yaml` for header navigation links (even if `geekdocMenuBundle = false`)
- `description` under `[params]` not at top level for template access
- Shortcodes (`expand`, `include`, `csv-table`) for content authoring parity with reference repos

### 2026-XX-XX: Bootstrap Docs — Backend Config Fix

**Problem:** Four docs pages (`bootstrap/_index.md`, `github-actions.md`, `azure-devops.md`, `deploy/_index.md`) told users to hardcode backend settings (resource_group_name, storage_account_name, container_name, key) directly in `infra/terraform/terraform.tf`. This contradicts the design: the empty `backend "azurerm" {}` block is intentional, and the OIDC bootstrap repos inject backend config at runtime via `-backend-config` CLI args.

**Fixes applied:**
1. **bootstrap/_index.md** — Added "Backend configuration" section explaining the empty backend block pattern, linking to the `example-module` reference in the bootstrap repo
2. **github-actions.md** — Replaced Step 3 (hardcoded HCL backend block + YAML workflow snippet) with `example_repo` guidance, explanation that no terraform.tf changes are needed, and local dev instructions using `-backend-config` args
3. **azure-devops.md** — Same fix as github-actions.md, with Azure DevOps-specific links
4. **deploy/_index.md** — Replaced hardcoded backend HCL block with `-backend-config` CLI arg examples and explanation that the bootstrap pipeline handles this automatically

**Key lesson:** When the CI/CD bootstrap handles state configuration at runtime, infrastructure code should keep backend blocks empty. Documentation must reflect this runtime injection pattern, not show hardcoded values that users would need to manually fill in.

### 2026-XX-XX: Hugo Docs Cleanup — Customer Journey Restructure

**Problem:** Docs had 7 content sections (Home, Getting Started, Terraform, Bicep, Bootstrap, Architecture, Examples) with redundancy between pages and filler paragraphs. Architecture was useful reference but added reading time without actionable steps. Terraform and Bicep pages duplicated deploy commands that belonged together.

**Restructured to 6-step customer journey:**
1. **Home** (`_index.md`) — 2 paragraphs: what it is, what you get, link to Getting Started
2. **Getting Started** (`getting-started/`) — Prerequisites, clone, choose tool, choose scenario, deploy.ps1, CI/CD link
3. **Bootstrap CI/CD** (`bootstrap/`) — Trimmed parent page, added `example_repo` guidance for pointing pipelines at `infra/terraform/` or `infra/bicep/`. Sub-pages (GitHub Actions, Azure DevOps) cut ~50% by removing "What gets created" tables (already on parent), "Key features" bullets, "Environment strategy" tables, and "Resources" link lists
4. **Deploy** (`deploy/`) — NEW. Interactive `deploy.ps1`, manual Terraform commands, manual Bicep commands, variable/parameter reference tables (migrated from removed Terraform/Bicep pages), state backend config, CI/CD pipeline flow
5. **ALZ Integration** (`alz-integration/`) — NEW. Brief spoke-only explainer, Terraform and Bicep parameter examples for hub peering, link to ALZ IaC Accelerator
6. **Examples** (`examples/`) — Clean scenario table with 1-line descriptions, feature flag examples, sample app link. Removed "Related patterns" filler

**Removed sections:**
- `docs/content/terraform/` — Variable reference and state backend moved to Deploy page
- `docs/content/bicep/` — Parameter reference moved to Deploy page
- `docs/content/architecture/` — Hub networking info moved to ALZ Integration page; design area guidance removed (CAF/WAF docs are better sources)

**Content reduction:** 8 files, ~15KB total. Readable in under 5 minutes. Every sentence teaches or instructs — no filler paragraphs.

**Key lesson:** Docs that mirror a customer journey (prerequisites → configure → deploy → integrate) are more useful than docs organized by technology (Terraform page, Bicep page, Architecture page). Fold tool-specific details into the step where the user needs them.

### 2024-03-24: Legacy File Cleanup

**Removed 201 files (~38,300 lines) of superseded code:**
- `scenarios/` (entire folder) — legacy Terraform, Bicep, ARM, and shared modules replaced by `infra/` AVM pattern modules
- Legacy GitHub Actions workflows (`.template.*.yml`, `scenario1.*.yml`, `platform.terraform-dependencies.yml`) — replaced by OIDC bootstrap
- `.github/actions/templates/` (tfApply, tfValidatePlan composite actions) — no longer needed
- Empty `.gitmodules` file

**Post-cleanup repo structure:** Root contains only `infra/`, `bootstrap/`, `docs/`, `sampleapp/`, `deploy.ps1`, `.squad/`, config files, and standard community files. No legacy `scenarios/` path references remain in active code.

**Key lesson:** When refactoring a repo structure, remove old files in a single dedicated cleanup commit after the new implementation is in place. This makes the migration reversible (one commit to revert) and the diff clearly shows what was replaced.

### 2026-XX-XX: Post-Refactor Quality Pass

**Comprehensive review of the entire repo after the AVM migration. Found and fixed 7 categories of issues:**

1. **`.gitignore` — Example tfvars untracked.** The blanket `*.tfvars` rule blocked all 9 example files in `infra/terraform/examples/`. Added `!infra/terraform/examples/*.tfvars` exception and force-added the files.

2. **`infra/terraform/README.md` — Three errors.** Variable table said `resource_group_id` (should be `resource_group_name`); GitHub Actions CI/CD link text said `azure-devops-terraform-oidc-ci-cd` (should be `github-terraform-oidc-ci-cd`); quick start referenced non-existent `terraform.tfvars.example` (should be `examples/asp-linux-app.tfvars`); prerequisites incorrectly stated "existing resource group" (the module creates it).

3. **Root `README.md` — Stale Quick Links.** Referenced `/terraform/` and `/bicep/` docs pages that were removed during the customer journey restructure. Updated to `/deploy/` and `/alz-integration/`.

4. **`.github/dependabot.yml` — 9 legacy `scenarios/` paths.** All Terraform entries pointed to non-existent `scenarios/secure-baseline-*` directories. Replaced with a single `infra/terraform` entry.

5. **`docs/content/deploy/_index.md` — Fictional variables and wrong file names.** Terraform variable table listed non-existent variables (`workload_name`, `deploy_sql`, `route_table_id`, etc.). Bicep section referenced `main.parameters.jsonc` instead of `main.bicepparam`. Both tables updated to match actual `variables.tf` and `main.bicep`.

6. **`docs/content/examples/_index.md` — Scenario table didn't match actual examples.** Listed conceptual scenarios (With Azure SQL, With Redis) that don't exist as example files. Replaced with the actual 9 example files across Terraform and Bicep. Feature flag code snippets updated to match real variable names.

7. **`docs/content/alz-integration/_index.md` — Wrong Terraform variable and Bicep format.** Terraform section used `route_table_id` (doesn't exist) instead of `hub_firewall_private_ip` + `hub_route_table_address_spaces`. Bicep section used ARM JSON format instead of `.bicepparam` syntax.

**What passed review (no issues):**
- Repo structure matches PRD target state (no `scenarios/`, no legacy workflows)
- `terraform.tf` has correct empty `backend "azurerm" {}` block
- `main.tf` and `main.bicep` correctly use AVM pattern + RG modules
- All 9 Terraform and 9 Bicep example files are consistent and well-structured
- `hugo.toml` has correct baseURL; Hugo builds with 0 errors/warnings
- `deploy.ps1` references correct example file paths and bootstrap repos
- `docs/.gitignore` properly covers `themes/hugo-geekdoc/` and `public/`
- Bootstrap docs correctly describe empty backend block and `-backend-config` pattern

**Key lesson:** After a major refactoring, docs pages are the most common source of stale references. Variable tables, parameter examples, and file path references all need to be cross-checked against the actual code — they frequently reference old variable names or non-existent files from the pre-refactoring design.

### 2026-XX-XX: ALZ Prerequisite Documentation Pass

**Problem:** Hugo docs site didn't make it clear that a Platform Landing Zone is a prerequisite. Users could attempt deployment without hub networking in place.

**Fixes applied across 5 docs pages:**
1. **Home (`_index.md`)** — Added `{{< hint type=important >}}` callout: Platform Landing Zone required, link to ALZ IaC Accelerator (aka.ms/alz/acc)
2. **Getting Started** — Restructured Prerequisites to lead with ALZ/hub requirements; added callout explaining the spoke assumes hub VNet peering, centralized firewall routing, and DINE diagnostics; added Terraform ≥ 1.9 version requirement
3. **Deploy** — Added `{{< hint type=note >}}` at top: users must provide hub VNet ID and firewall IP from their Platform Landing Zone deployment
4. **ALZ Integration** — Strengthened from optional guidance to required: "ALZ integration is not optional" callout, expanded description of platform-level concerns (peering, firewall egress, DINE diagnostics)
5. **Examples** — Added callout: "All examples assume deployment into an Azure Platform Landing Zone"

**Key lesson:** When a project is designed for integration with a platform (ALZ), every entry point in the docs needs to state that dependency. Users land on different pages — the prerequisite must be visible on home, getting started, deploy, and examples, not just on a dedicated integration page.
