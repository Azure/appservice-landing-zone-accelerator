# Project Context

- **Owner:** Jared Holgate
- **Project:** Refactoring the App Service Landing Zone Accelerator to leverage Azure Verified Modules (AVM) for Terraform and Bicep, plus CI/CD bootstrapping with OIDC
- **Stack:** Terraform, Bicep, Azure (App Service, Front Door, Firewall, VNet, Key Vault, SQL, Redis, and more), GitHub Actions, Azure DevOps
- **Repo:** appservice-landing-zone-accelerator
- **Key reference repos:** Azure-Samples/azure-devops-terraform-oidc-ci-cd, Azure-Samples/github-terraform-oidc-ci-cd
- **Created:** 2026-03-24

## Repo Structure

- `.github/workflows/` — GitHub Actions deployment workflows (Terraform + Bicep)
- `.github/actions/templates/` — Reusable composite actions (tfValidatePlan, tfApply)
- `.github/workflows/platform.terraform-dependencies.yml` — Terraform state prerequisites

## Key Reference Repos

- **azure-devops-terraform-oidc-ci-cd:** Bootstrap Terraform CI/CD with OIDC for Azure DevOps
- **github-terraform-oidc-ci-cd:** Bootstrap Terraform CI/CD with OIDC for GitHub Actions

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2026-03-24: Team Assembly & PRD Complete → Pattern Module Strategy Update

Team hired: Morpheus (Lead), Trinity (Terraform), Tank (Bicep), Switch (DevOps), Niobe (Docs/QA).

**Morpheus completed comprehensive PRD** (docs/PRD.md v1.0):
- 3 workstreams: Terraform AVM (6 weeks), Bicep AVM (5 weeks), CI/CD Bootstrap (2 weeks)
- 16 Terraform + 24 Bicep module mappings
- 10 architectural decisions documented
- Risk assessment and phased execution plan

**PATTERN MODULE DISCOVERY (v2.0):** AVM pattern modules for App Service LZA discovered; strategy updated. **Impact on Switch's work:** Timeline compressed (~18 weeks → ~14 weeks); Trinity/Tank phase times reduced. CI/CD bootstrap work unchanged.

**Switch's Responsibilities (UNCHANGED):**
- Integrate CI/CD bootstrap with OIDC for GitHub Actions and Azure DevOps
- New `bootstrap/` directory with both platforms, no secrets in repos, multi-environment support (dev/test/prod)
- Reference implementations: azure-devops-terraform-oidc-ci-cd, github-terraform-oidc-ci-cd (Microsoft-official)

**Decisions Affecting CI/CD Work:**
- Decision 3: CI/CD Bootstrap Integration — Core responsibility (GitHub Actions + Azure DevOps OIDC)
- Decision 9: No Platform Lock-In — Unchanged (parity across GitHub Actions and Azure DevOps)
- Decision 11 (NEW): Adopt AVM Pattern Modules — No impact on bootstrap scope; Terraform/Bicep phases reduce but bootstrap integration timeline stable
- Decision 15 (NEW): CI/CD Consolidation (OIDC-Only) — **Primary impact:** Remove all legacy CI/CD workflows; OIDC is ONLY auth method; no password-based examples; no PAT/SPN credentials
- See .squad/decisions.md for full decision log.

**Updated Switch Responsibilities:**
- Primary: OIDC bootstrap for GitHub Actions and Azure DevOps (unchanged scope, cleaner requirements)
- Remove: All legacy/password-based workflow examples
- Add: Clear OIDC-only guidance; no credential alternatives documented
- Simplify: Single auth method (OIDC) reduces bootstrap complexity; Decision 14 (no Portal/ARM) means CI/CD is ONLY deployment method

**Note:** Trinity/Tank will update state migration scripts and module configuration for pattern module approach; Switch coordinates bootstrap integration across shortened timeline with simplified auth model (OIDC-only).

### 2026-03-24: Bootstrap Folder Structure & Documentation Created

Created the `bootstrap/` directory at repo root with comprehensive documentation pointing users to the two Microsoft reference repos for OIDC CI/CD bootstrapping.

**Files created:**
- `bootstrap/README.md` — Overview of bootstrapping, platform comparison table, architecture diagram showing bootstrap → infra flow, prerequisites, security model
- `bootstrap/github-actions/README.md` — GitHub Actions-specific guide: links to `Azure-Samples/github-terraform-oidc-ci-cd`, quickstart steps, backend config examples, environment strategy
- `bootstrap/azure-devops/README.md` — Azure DevOps-specific guide: links to `Azure-Samples/azure-devops-terraform-oidc-ci-cd`, quickstart steps, service connection examples, platform comparison

**Key design choices:**
- Documentation-only approach: we point users to the existing Microsoft repos rather than duplicating Terraform code. This keeps maintenance burden on the reference repos and avoids drift.
- Both platform guides follow identical structure (What Gets Created → Key Features → Prerequisites → Quickstart → Connect to Infra → Environment Strategy → Clean Up → Resources) for consistency.
- Backend config examples use `use_oidc = true` and reference bootstrap outputs, making the connection from bootstrap to `infra/` concrete.
- No legacy/password-based examples anywhere — OIDC-only per Decision 15.

### 2026-03-24: Interactive deploy.ps1 Created

Created `deploy.ps1` at repo root — an interactive PowerShell deployment script that guides users through all deployment paths.

**What it does:**
- Prerequisite checks: az CLI, terraform, gh CLI, Azure DevOps extension, and az login status
- 4 deployment paths: Bootstrap GitHub Actions, Bootstrap Azure DevOps, Local Terraform, Local Bicep
- 9 hosting scenarios mapped to example files in `infra/terraform/examples/` and `infra/bicep/examples/`
- Gathers user inputs (location, resource group, environment, workload name) and substitutes them into example files
- Bootstrap paths clone the Microsoft reference repos (`Azure-Samples/github-terraform-oidc-ci-cd`, `Azure-Samples/azure-devops-terraform-oidc-ci-cd`) and generate bootstrap tfvars pointing at this repo's `infra/terraform/`
- Local Terraform path copies example `.tfvars` to `terraform.tfvars`, runs `terraform init/plan/apply`
- Local Bicep path generates `deploy-<scenario>.bicepparam` and runs `az deployment sub create`
- `-WhatIf` parameter shows what would happen without executing
- Cross-platform: Windows PowerShell and PowerShell Core
- Colored output (cyan prompts, green success, red errors)
- Confirmation prompts before destructive operations

**Key design choices:**
- No external PowerShell modules required — uses only built-in cmdlets
- Bootstrap directories (`.bootstrap-github/`, `.bootstrap-azdo/`) are gitignored
- Bicep workload names auto-truncated to 10 chars (Bicep param constraint)
- OIDC-only for bootstrap paths — no PAT/SPN credential storage (per Decision 15)

### 2026-03-24: Refactored deploy.ps1 — Removed Redundant Variable Mappings

Removed 123 lines of dead code from `deploy.ps1`. The `$TfScenarioConfig` and `$BicepScenarioConfig` hashtables duplicated scenario-specific values (OS type, SKU, feature toggles) that already exist in the example `.tfvars` and `.bicepparam` files under `infra/terraform/examples/` and `infra/bicep/examples/`.

The script was already using the correct approach: copy the example file and use `-replace` to substitute only user-provided values (location, resource group, environment, workload name). The mapping blocks were vestigial from an earlier design and never consumed.

**Also removed:** Unused `$tfExampleFile` variables in both bootstrap functions and the `$scenarioConfig` assignment in `Invoke-LocalBicep`.

**Key insight:** The example files ARE the source of truth for scenario configuration. The script's only job is to substitute the handful of user-specific values (location, RG name, environment, workload) — everything else (SKU, OS type, feature flags, networking) should come from the example file unchanged.

