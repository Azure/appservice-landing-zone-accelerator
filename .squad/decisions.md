# Squad Decisions

## Active Decisions

### Decision 1: AVM-First Strategy
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** Deciding how to handle custom modules vs. AVM modules

**Decision:** Adopt "AVM-First" strategy — replace all custom modules with AVM equivalents where available. Keep scenario-specific wrappers for composition logic.

**Rationale:**
- Microsoft maintains AVM modules, reducing our maintenance burden
- AVM modules are Well-Architected Framework aligned
- Consistent interfaces across modules improve developer experience
- Access to continuous updates for new Azure features

**Implications:**
- All 16 Terraform custom modules will be replaced
- All Bicep shared modules will be replaced
- Scenario-specific wrappers (`scenarios/secure-baseline-multitenant/bicep/modules/`) will be kept but refactored
- State migration required for existing deployments

---

### Decision 2: Terraform-First Migration Approach
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** Choosing whether to migrate Terraform or Bicep first

**Decision:** Migrate Terraform implementation first, then Bicep. Both can run in parallel with separate teams.

**Rationale:**
- Terraform has more complex module structure (16 modules with child modules)
- Terraform state migration is more intricate than Bicep Deployment Stacks
- Learning from Terraform migration can inform Bicep approach
- Parallelization possible with two-team setup

**Implications:**
- Terraform migration: Weeks 3-8 (6 weeks)
- Bicep migration: Weeks 9-13 (5 weeks)
- Can start in parallel with dedicated resources

---

### Decision 3: CI/CD Bootstrap Integration
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** How to integrate OIDC bootstrap into the repo

**Decision:** Add `bootstrap/` directory at root with GitHub Actions and Azure DevOps OIDC bootstrap solutions, adapted from Microsoft reference repos.

**Rationale:**
- OIDC is modern security standard (no secrets in repos)
- Reference implementations are proven and Microsoft-supported
- Both GitHub Actions and Azure DevOps users should be supported
- Bootstrap should be optional (not forced on existing users)

**Implications:**
- New directory: `bootstrap/github-actions/` and `bootstrap/azure-devops/`
- Existing workflows updated to use OIDC (but old method documented)
- State management moves to bootstrap-created storage account
- Multi-environment support (dev/test/prod) added

---

### Decision 4: Keep Scenario-Specific Wrappers
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** Should scenario-specific modules be kept or removed?

**Decision:** Keep scenario-specific wrapper modules (e.g., `app-service.module.bicep`, `keyvault.module.bicep`) but refactor them to use AVM modules internally.

**Rationale:**
- Wrappers provide solution-specific composition (private endpoint + DNS + RBAC)
- They encapsulate Landing Zone Accelerator patterns
- Removing them would increase complexity in main orchestration
- They add value beyond what AVM provides

**Implications:**
- Bicep modules in `scenarios/secure-baseline-multitenant/bicep/modules/` are refactored, not removed
- Wrappers become thin layers over AVM modules
- Reduces custom code while preserving solution patterns

---

### Decision 5: Pin AVM Module Versions
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** Should we use latest AVM versions or pin to specific versions?

**Decision:** Pin all AVM module versions in production code. Document version update process.

**Rationale:**
- Prevents unexpected breaking changes
- Allows controlled testing of new versions
- Aligns with infrastructure-as-code best practices
- Provides stability for users

**Implications:**
- All module references include version constraint (e.g., `version = "0.7.1"`)
- Version update process documented
- Testing required before version bumps
- Version matrix maintained in PRD appendix

---

### Decision 6: State Migration Strategy
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** How to handle Terraform state when module addresses change?

**Decision:** Provide state migration scripts using `terraform state mv`. Document manual migration steps. Offer "blue/green" approach for complex scenarios.

**Rationale:**
- Resource addresses change when switching from custom modules to AVM
- Users need clear migration path
- Automation reduces errors
- Blue/green approach provides safety net

**Implications:**
- Migration scripts created for each module replacement
- Documentation includes step-by-step manual process
- Testing required in non-production first
- Rollback plan documented

---

### Decision 7: Non-Goals — Sample App Unchanged
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** Should the ASP.NET Core sample app be updated?

**Decision:** No changes to sample application. It remains as-is.

**Rationale:**
- Sample app demonstrates workload deployment, not infrastructure
- Changes would expand scope unnecessarily
- App should work with new infrastructure (validation point)
- Focus should be on IaC refactoring

**Implications:**
- `sampleapp/` directory untouched
- Deployment of sample app is validation step
- If sample app breaks, infrastructure migration has failed

---

### Decision 8: Phased Rollout (7 Phases per Workstream)
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** How to structure the migration work?

**Decision:** Use 7-phase approach for both Terraform and Bicep:
1. Foundation (Networking & Observability)
2. Security & Connectivity
3. App Platform
4. Data & State
5. AI & Front Door
6. Compute & DevOps
7. Integration & Testing

**Rationale:**
- Builds from foundation up (networking first)
- Each phase is independently testable
- Reduces risk of "big bang" migration
- Allows incremental progress tracking

**Implications:**
- Migration takes 6-8 weeks per language
- Each phase must pass validation before next starts
- Integration testing only after all phases complete
- Git branch strategy needed for work-in-progress

---

### Decision 9: No Platform Lock-In (GitHub + Azure DevOps)
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** Should we standardize on one CI/CD platform?

**Decision:** Support both GitHub Actions and Azure DevOps with parity. Users choose their platform.

**Rationale:**
- Enterprise customers use both platforms
- Microsoft supports both (reference implementations exist)
- Platform choice is organizational, not technical
- Flexibility increases adoption

**Implications:**
- Bootstrap solutions for both platforms
- Workflows/pipelines updated for both
- Documentation covers both approaches
- No platform is "second-class"

---

### Decision 10: Documentation Over Code Comments
**Date:** 2024-03-24  
**Made by:** Morpheus  
**Context:** How to document the migration and new patterns?

**Decision:** Create comprehensive external documentation (migration guide, bootstrap runbooks, troubleshooting) rather than relying on inline comments.

**Rationale:**
- AVM modules are self-documenting via registry
- Inline comments create maintenance burden
- External docs are more discoverable
- Aligns with Landing Zone Accelerator's existing doc structure

**Implications:**
- New files: `docs/migration-guide.md`, `bootstrap/README.md`, troubleshooting guides
- Code comments minimal (only for complex logic)
- README files updated
- Architecture docs updated to reference AVM

---

### Decision 11: Adopt AVM Pattern Modules as Primary Migration Strategy
**Date:** 2026-03-24  
**Made by:** Morpheus  
**Status:** Active (approved by team)
**Context:** Discovery that AVM pattern modules exist for the App Service Landing Zone, fundamentally changing migration approach from "replace 40+ custom modules one-by-one" to "one pattern module call + supplemental resource modules."

**Decision:** Use AVM pattern modules as the primary building block for App Service Landing Zone migration, supplemented by individual resource modules only where pattern module coverage is insufficient.

**Rationale:**
- **Massive simplification:** One pattern module call replaces 12 Terraform and 22 Bicep custom modules
- **Reduced maintenance:** Microsoft maintains the pattern module, eliminating custom composition burden
- **Faster delivery:** Single module to configure, test, and validate vs. 40+ individual modules
- **Better alignment:** Pattern module IS the App Service LZA reference architecture (packaged as AVM)
- **Continuous updates:** Pattern module receives architectural improvements from Microsoft
- **Repo focus shift:** Project becomes configuration + supplements + documentation (not IaC authoring)

**Implications:**
- **Updates Decision 1 (AVM-First):** Strategy evolves from "replace with resource modules" to "replace with pattern module + supplementals"
- **Updates Decision 4 (Keep Scenario Wrappers):** Most wrappers become unnecessary; pattern module handles composition
- **Updates Decision 8 (Phased Rollout):** Phases reduced from 7 to 5; pattern module validates as complete unit
- **Timeline:** Reduced from ~18 weeks to ~14 weeks
- **Scope:** Terraform modules 16→1 primary; Bicep modules 24→1 primary; supplemental resource modules (Firewall, SQL, Redis, OpenAI, App Config, VM) still needed
- **Module references:**
  - **Terraform:** `Azure/avm-ptn-app-service-landing-zone/azure` (registry.terraform.io)
  - **Bicep:** `br/public:avm/ptn/app-service-lza/hosting-environment` (v0.2)

**New Risks:**
- Pattern module maturity (v0.2 for Bicep is relatively new)
- State migration complexity (all resource addresses change at once vs. incrementally)
- Must validate pattern module covers all LZA-specific requirements

**Affected Files:**
- `docs/PRD.md` — Updated to v2.0 with pattern module strategy
- `scenarios/shared/terraform-modules/` — Will be removed (replaced by pattern module + supplements)
- `scenarios/shared/bicep/` — Will be removed (replaced by pattern module + supplements)

---

### Decision 12: Hub Networking Deferred to ALZ IaC Accelerator
**Date:** 2026-03-24  
**Made by:** Morpheus  
**Status:** Active  
**Context:** User requested scope reduction to focus on App Service Landing Zone; hub networking is better handled by Azure Landing Zones IaC Accelerator.

**Decision:** Remove all hub networking infrastructure and hub-spoke orchestration from scope. Hub networking is deferred to the Azure Landing Zones IaC Accelerator project.

**Rationale:**
- Hub networking is complex and spans multiple landing zones (enterprise-scale concern)
- Azure Landing Zones IaC Accelerator is the appropriate home for hub architecture
- App Service Landing Zone should assume hub exists and focus on spoke-level resources
- Reduces scope and allows focus on App Service-specific infrastructure

**Implications:**
- Hub-spoke networking model split removed (spoke only)
- Hub resource templates removed from scenarios
- Hub state management removed
- Documentation clarifies assumption: hub provided by ALZ IaC Accelerator
- Integration points to ALZ documented
- State migration simplified (no hub resource address changes)

---

### Decision 13: Folder Structure Flattened to infra/
**Date:** 2026-03-24  
**Made by:** Morpheus  
**Status:** Active  
**Context:** Nested folder structure (`scenarios/secure-baseline-multitenant/terraform/`, `scenarios/shared/terraform-modules/`) reduces discoverability and adds cognitive overhead.

**Decision:** Flatten folder structure to `infra/` at root level. Terraform and Bicep share root `infra/` with `infra/terraform/`, `infra/bicep/`, and `infra/modules/` subdirectories.

**Rationale:**
- Flatter structure improves discoverability and reduces navigation burden
- Aligns with modern IaC repository conventions (terraform module repos, Bicep module repos)
- Clearer separation: code vs. configuration vs. bootstrap vs. docs
- Simplifies documentation (fewer folder levels to reference)

**Implications:**
- All references to `scenarios/secure-baseline-multitenant/terraform/` → `infra/terraform/`
- All references to `scenarios/shared/terraform-modules/` → `infra/modules/`
- All references to `scenarios/secure-baseline-multitenant/bicep/` → `infra/bicep/`
- Documentation updated throughout
- CI/CD workflows updated to reference new paths
- README files updated

---

### Decision 14: Portal & ARM Templates Out of Scope
**Date:** 2026-03-24  
**Made by:** Morpheus  
**Status:** Active  
**Context:** Project is IaC-first (Terraform + Bicep); Portal and ARM templates create maintenance burden and dilute project focus.

**Decision:** Remove all Azure Portal deployment templates and ARM template options from scope. All deployment paths flow through Infrastructure-as-Code (Terraform or Bicep) + CI/CD pipeline.

**Rationale:**
- Portal deployments are not repeatable or auditable (manual clicking not code)
- ARM templates are legacy; Bicep is modern alternative
- IaC is the canonical definition of infrastructure; no parallel deployment mechanisms
- Reduces maintenance burden and cognitive load
- Aligns with GitOps and infrastructure-as-code best practices

**Implications:**
- No Portal quick-deploy templates maintained
- No ARM template alternatives provided
- All deployment examples use Terraform or Bicep
- Documentation focuses on CI/CD pipeline usage
- Users must use code-based deployment (eliminates click-through deployments)

---

### Decision 15: CI/CD Consolidation (OIDC-Only)
**Date:** 2026-03-24  
**Made by:** Morpheus  
**Status:** Active  
**Context:** Legacy CI/CD workflows with password-based authentication create security risk and technical debt. OIDC is modern standard; all users should use passwordless auth.

**Decision:** Remove all legacy CI/CD workflows and password-based authentication examples. Only OIDC-based CI/CD workflows remain (GitHub Actions and Azure DevOps).

**Rationale:**
- OIDC is cloud-native security standard (passwordless, certificate-based)
- No secrets in repositories (eliminates credential exposure risk)
- Legacy workflows create maintenance burden and security debt
- Both GitHub Actions and Azure DevOps have native OIDC support
- Aligns with industry best practices and Microsoft guidance

**Implications:**
- `.github/workflows/` — Legacy workflows removed; only OIDC GitHub Actions remain
- Azure DevOps pipelines — Modernized to use OIDC service connections
- Bootstrap documentation emphasizes OIDC setup (no legacy examples)
- No PAT or SPN credentials stored in repos
- Users follow modern deployment pattern (OIDC bootstrap + code-based deployment)
- State backend authentication via OIDC (no storage account keys)

---

### Decision 16: Terraform Initial Setup — AVM Pattern Module v0.1.0

**Date:** 2026-03-24  
**Author:** Trinity (Terraform Dev)  
**Status:** Implemented

#### Context

Created `infra/terraform/` as the canonical Terraform deployment for the App Service Landing Zone Accelerator using AVM pattern modules.

#### Decisions Made

1. **Module version pinned to v0.1.0** — First published release on the Terraform registry. Per Decision 5, versions are pinned. Will update when newer versions are validated.

2. **`key_vault_enabled` defaults to `true`** — The upstream module defaults to `false`, but an LZA should include secrets management by default. Users can disable it if they have an existing Key Vault.

3. **Hub peering derived from variables** — Rather than exposing `alz_platform_landing_zone_peer_to_hub_enabled` directly, the config derives it: if `hub_virtual_network_id` is set, peering is enabled. Same pattern for the route table via `hub_firewall_private_ip`. This simplifies the user-facing interface.

4. **Resource group is not created** — The pattern module requires `parent_id` (an existing resource group ID). This aligns with the ALZ model where resource groups are managed at a higher scope.

5. **No backend configuration** — Backend (state storage) is left to the user/CI pipeline, consistent with the OIDC bootstrap repos providing state backend setup.

#### Implications

- Supplemental modules (SQL, Redis, OpenAI, etc.) will be added in future phases
- State migration scripts will need to map from the old module addresses to the pattern module's resource structure

---

### Decision 17: Bicep Pattern Module Version Pin & Parameter Style

**Date:** 2026-03-24  
**Author:** Tank (Bicep Dev)  
**Status:** Implemented

#### Context

Creating the initial `infra/bicep/` implementation using the AVM pattern module for App Service Landing Zone.

#### Decisions Made

1. **Pin to version `0.2.0` (not `0.2`)** — The PRD referenced the module as version `0.2`, but the Bicep Public Registry uses full semver tags. Pinned to `0.2.0` as the latest release.

2. **Use `.bicepparam` format (not `.parameters.json`)** — Chose native Bicep parameter files with `using 'main.bicep'` for type safety, IntelliSense, comments, and no schema URL boilerplate.

3. **Expose hub integration as top-level params** — Promoted `hubVnetResourceId` and `firewallInternalIp` to top-level parameters with empty-string defaults. The main.bicep maps them into the config object with null-coalescing. This makes the hub connection story clear.

4. **FTPS set to `Disabled` (not `FtpsOnly`)** — Changed to `Disabled` since basic publishing credentials are already disabled and FTPS is legacy. All deployments should use CI/CD.

#### Affected Files

- `infra/bicep/main.bicep`
- `infra/bicep/main.bicepparam`
- `infra/bicep/README.md`

---

### Decision 18: Bootstrap as Documentation-Only (No Code Duplication)

**Date:** 2026-03-24  
**Made by:** Switch (DevOps Engineer)  
**Status:** Implemented

#### Context

The `bootstrap/` directory could either (a) duplicate Terraform code from the reference repos into this repo, or (b) provide documentation that points users to the canonical Microsoft repos.

#### Decision

Documentation-only approach. The `bootstrap/` folder contains README guides that link to `Azure-Samples/github-terraform-oidc-ci-cd` and `Azure-Samples/azure-devops-terraform-oidc-ci-cd` with quickstart instructions and integration examples — but no copied Terraform code.

#### Rationale

- **No drift** — If the reference repos update (new features, bug fixes, security patches), users automatically get the latest by cloning those repos. Duplicated code would drift.
- **Single source of truth** — Microsoft maintains the reference repos. Copying code creates a fork that we'd need to maintain.
- **Reduced scope** — We document *how to connect* bootstrap outputs to `infra/`, which is the value-add. The bootstrap Terraform itself is not our code to own.
- **Aligns with Decision 10** — Documentation over code comments; external docs are more discoverable.

#### Implications

- Users clone the reference repo separately to run bootstrap (two repos involved)
- We own the integration guidance (backend config, OIDC workflow examples) but not the bootstrap Terraform
- If reference repos change their interface, our docs may need updating

---

### Decision 19: Validation Toolchain for infra/ Structure

**Date:** 2026-03-24  
**Made by:** Niobe (Tester/QA)  
**Status:** Implemented

#### Context

With the migration to `infra/terraform/` and `infra/bicep/` using AVM pattern modules, the validation toolchain needs updating to support the new structure and modernize tool selections.

#### Decision

Adopt the following validation toolchain for the new `infra/` structure:

1. **Trivy replaces tfsec** — tfsec is deprecated; Trivy subsumes it. Migrate the existing `.tfsec/_tfsec.yml` custom check (CUS001) to a Trivy custom policy.
2. **PSRule stays for Bicep** — PSRule for Azure validates `.bicepparam` files against Azure WAF rules. Current config works with new paths (glob-based). Pin to `>=1.35.0`.
3. **Pre-commit hooks expanded** — Add `terraform_validate` and `terraform_tflint` for `infra/terraform/`; add Trivy hooks for both languages. Keep legacy hooks for `scenarios/` until migration is complete.
4. **Four-gate quality model** — Static Analysis → Security Scanning → Plan Verification → Post-Deployment Smoke Tests. All gates documented in `infra/validation-plan.md`.
5. **Trivy-only for Terraform security** — Do not add PSRule for Terraform; Trivy provides sufficient coverage without adding another tool to the Terraform pipeline.

#### Rationale

- tfsec → Trivy is an industry-standard migration (Aqua Security recommendation)
- PSRule is the best-in-class tool for Bicep/ARM WAF validation
- Four gates catch different failure modes (syntax, security, drift, runtime)
- Keeping legacy hooks avoids breaking existing contributors during migration

#### Implications

- `.tfsec/_tfsec.yml` will need a Trivy custom policy equivalent (CUS001 migration)
- `.psrule/ps-rule.yaml` version pin should be updated to `>=1.35.0`
- CI/CD pipelines should incorporate all four gates
- Pattern module outputs need validation test coverage

#### Affected Files

- `infra/validation-plan.md` — new validation strategy document
- `.pre-commit-config.yaml` — updated with new hooks
- `.tfsec/_tfsec.yml` — flagged for migration to Trivy
- `.psrule/ps-rule.yaml` — flagged for version pin update

---

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction


## Decision 16: Adopt Hugo with hugo-geekdoc for Documentation


## Decision 16: Adopt Hugo with hugo-geekdoc for Documentation

**Context:** Documentation was scattered across `docs/Design-Areas/` (legacy markdown files), `bootstrap/` READMEs, and the root `README.md`. This fragmented structure made it hard to find information and didn't provide a modern web experience.

**Decision:** Restructure all documentation into a Hugo static site in `docs/`, matching the pattern used by `Azure/Azure-Landing-Zones`. Use the `hugo-geekdoc` theme. Publish to GitHub Pages at `https://azure.github.io/appservice-landing-zone-accelerator`.

**What changed:**
1. Removed `docs/Design-Areas/` (6 legacy markdown files) and `docs/App-Service-LZA.vsdx`
2. Created Hugo site structure: `hugo.toml`, `archetypes/`, `content/`, `static/`, `themes/`, `layouts/`, `assets/`, `data/`
3. Created content sections: home, getting-started, terraform, bicep, bootstrap (with github-actions + azure-devops sub-pages), architecture, examples
4. Moved bootstrap docs content from `bootstrap/` READMEs into Hugo content pages
5. Replaced `bootstrap/` READMEs with thin pointers to the Hugo docs site
6. Simplified root `README.md` to a minimal landing page with docs site links
7. Preserved existing architecture images in `docs/static/img/`

**Rationale:**
- Matches the `Azure/Azure-Landing-Zones` documentation pattern (consistency across ALZ ecosystem)
- `hugo-geekdoc` provides search, dark mode, breadcrumbs, ToC, edit-on-GitHub links
- Single source of truth for all docs — no duplication across README files
- GitHub Pages hosting gives a professional, discoverable documentation site
- LLM-friendly output format (TXT output for llms.txt)

**Implications:**
- Hugo + `hugo-geekdoc` theme must be installed to build docs locally (git submodule or Hugo module)
- GitHub Pages deployment workflow needed (not created in this PR — follow-up task)
- Old `docs/Design-Areas/` links in external references will break (design area content was being replaced anyway)
- `bootstrap/` folder retained for non-doc content; READMEs now redirect to Hugo site

## Decision 17: Simplify Root README

**Context:** The root `README.md` was 200+ lines with inline deployment instructions, parameter tables, and workflow configuration — content better served by the Hugo docs site.

**Decision:** Replace the root README with a minimal ~20-line landing page linking to the Hugo documentation site.

**Rationale:**
- Root README should orient newcomers, not serve as the full manual
- All substantive content now lives in the Hugo docs site
- Matches the pattern of other Azure repos that use Hugo docs

