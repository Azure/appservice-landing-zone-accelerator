# Project Context

- **Owner:** Jared Holgate
- **Project:** Refactoring the App Service Landing Zone Accelerator to leverage Azure Verified Modules (AVM) for Terraform and Bicep, plus CI/CD bootstrapping with OIDC
- **Stack:** Terraform, Bicep, Azure (App Service, Front Door, Firewall, VNet, Key Vault, SQL, Redis, and more), GitHub Actions, Azure DevOps
- **Repo:** appservice-landing-zone-accelerator
- **Key reference repos:** Azure-Samples/azure-devops-terraform-oidc-ci-cd, Azure-Samples/github-terraform-oidc-ci-cd
- **Created:** 2026-03-24

## Repo Structure

- `.psrule/` — PSRule configuration for Azure best practices
- `.tfsec/` — tfsec security scanning configuration
- `.pre-commit-config.yaml` — Pre-commit hook configuration
- `scenarios/secure-baseline-multitenant/terraform/` — Terraform to validate
- `scenarios/secure-baseline-multitenant/bicep/` — Bicep to validate

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2026-03-24: Team Assembly & PRD Complete → Pattern Module Strategy Update

Team hired: Morpheus (Lead), Trinity (Terraform), Tank (Bicep), Switch (DevOps), Niobe (Docs/QA).

**Morpheus completed comprehensive PRD** (docs/PRD.md v1.0):
- 3 workstreams: Terraform AVM (6 weeks), Bicep AVM (5 weeks), CI/CD Bootstrap (2 weeks)
- 16 Terraform + 24 Bicep module mappings
- 10 architectural decisions documented
- Risk assessment and phased execution plan

**PATTERN MODULE DISCOVERY (v2.0):** AVM pattern modules for App Service LZA discovered; strategy updated to pattern-module-first approach. This significantly impacts Niobe's documentation scope.

**Niobe's Updated Responsibilities:**
- Migration documentation: Refocus from "40+ module replacement guide" to "pattern module deployment + supplemental modules"
- Bootstrap runbooks: Unchanged (still needed for GitHub Actions + Azure DevOps OIDC)
- Troubleshooting guides: New focus on pattern module edge cases, state migration (pattern module addresses change)
- Updated README files: Emphasize pattern module approach
- Architecture docs: Reference pattern module as primary building block
- Testing/QA: Validate pattern module covers all LZA requirements; validate zero regression with new approach

**Updated Scope:**
- Timeline compressed: ~18 weeks → ~14 weeks (shorter Terraform/Bicep phases)
- Phase reduction: 7 → 5 per workstream (pattern module validates as unit)
- Documentation refocus: Fewer custom module docs needed; more pattern module configuration + troubleshooting

**Decisions Affecting Documentation/QA Work:**
- Decision 10: Documentation Over Code Comments — Unchanged (external docs prioritized)
- Decision 11 (NEW): Adopt AVM Pattern Modules — Major scope shift: migration guide focuses on pattern module + risk mitigation
- Decision 12 (NEW): Hub Networking Deferred to ALZ IaC Accelerator — **Scope reduction:** Remove hub networking docs; add ALZ integration reference
- Decision 13 (NEW): Folder Structure Flattened to infra/ — **Update all docs:** Reference `infra/terraform/`, `infra/bicep/`, `infra/modules/`; remove nested scenario paths
- Decision 14 (NEW): Portal & ARM Templates Out of Scope — **Remove:** Portal quick-start docs; ARM template examples; clarify IaC-only deployment
- Decision 15 (NEW): CI/CD Consolidation (OIDC-Only) — **Simplify CI/CD docs:** OIDC-only bootstrap; remove legacy auth examples; no PAT/SPN guidance
- State Migration: Documentation must cover pattern module state migration (address changes differ from incremental module approach)
- See .squad/decisions.md for full decision log.

**Updated Niobe Responsibilities:**
- Migration guide: Pattern module focus + simplified (hub removal reduces scope)
- Bootstrap runbooks: OIDC-only (cleaner, no legacy alternatives)
- Troubleshooting: Pattern module edge cases + folder structure references
- README updates: New infra/ folder structure; IaC-only deployment path; ALZ integration points
- Architecture docs: Reference pattern modules; deferred hub networking
- Testing/QA: Pattern module validation + zero regression with new structure

**Testing Strategy Updated:**
- Validate zero functionality regression with new folder structure
- Ensure all scenarios deploy successfully with pattern module (spoke-only, no hub)
- Test state migration processes (now single-module migration vs. incremental)
- Verify documentation accuracy (folder references, deployment examples)

### 2026-03-24: Validation Plan Created for infra/ Structure

Created `infra/validation-plan.md` — comprehensive validation strategy covering four quality gates:
1. **Static Analysis:** terraform validate/fmt/tflint for TF; az bicep build + linter for Bicep
2. **Security Scanning:** Trivy (replacing deprecated tfsec) for both; PSRule for Bicep WAF compliance
3. **Plan Verification:** terraform plan -detailed-exitcode; az deployment sub what-if
4. **Post-Deployment Smoke Tests:** resource existence, private endpoint DNS, app reachability, supplemental resources

**Key findings during review:**
- `.tfsec/_tfsec.yml` has custom check CUS001 (empty backend block) — needs migration to Trivy custom policy
- `.psrule/ps-rule.yaml` glob patterns already work for `infra/bicep/` paths (no path change needed)
- `.pre-commit-config.yaml` only had Terraform hooks; updated to add `terraform_validate`, `terraform_tflint` for `infra/terraform/`, plus Trivy hooks for both languages
- `terraform_validate` was disabled due to OpenAI module issues — re-enabled for `infra/terraform/` since pattern module approach eliminates that blocker
- PSRule version pin should move from `>=1.29.0` to `>=1.35.0` for AVM awareness
- Proposed decision: Trivy-only for Terraform security (no PSRule for TF) to keep toolchain simple

**Files created/updated:**
- `infra/validation-plan.md` (new)
- `.pre-commit-config.yaml` (updated with infra/ hooks)
- `.squad/decisions/inbox/niobe-validation-plan.md` (proposed decision)

### 2026-03-24: Full Repo Validation Pass

Ran comprehensive validation across all code and config:

**Passed (no issues):**
- `terraform init -backend=false` + `terraform validate` — clean
- `az bicep build --file infra/bicep/main.bicep` — clean
- Hugo docs build — 28 pages, zero errors
- `deploy.ps1` PowerShell syntax — clean
- All 9 example `.tfvars` files reference only variables defined in `variables.tf`
- All 9 example `.bicepparam` files correctly use `'../main.bicep'`
- No stale `.template.terraform.yml` / `.template.bicep.yml` references in active code
- No stale `azure-resource-manager` references in active code (only in docs URLs and `.squad/` history)
- `hub` references in `infra/` are limited to ALZ peering params (`hub_virtual_network_id`, `hub_firewall_private_ip`, `hub_route_table_address_spaces`) — correct per Decision 12

**Fixed:**
- `.github/dependabot.yml` — replaced 9 stale `scenarios/` directory paths with single `/infra/terraform` entry (commit `040371d`)
- `terraform fmt` — all 9 example `.tfvars` files were auto-formatted (already staged, no net change)

**Stale `scenarios/` references remaining (acceptable):**
- `.squad/` history and PRD files (project documentation, expected)
- `infra/terraform/README.md` line 79 — external Microsoft Learn URL, not a local path
- `.github/agents/squad.agent.md` — references docs page paths, not old directory structure
- `.copilot/skills/docs-standards/SKILL.md` — template reference to docs page categories

