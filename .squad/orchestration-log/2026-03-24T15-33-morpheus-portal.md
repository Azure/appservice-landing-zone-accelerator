# Morpheus Round 2: Portal/ARM & Legacy Template Removal

**Timestamp:** 2026-03-24T15:33:00Z  
**Agent:** Morpheus (Lead/Architect)  
**Mode:** background  
**Status:** Complete

## Work Summary

User requested removal of Portal and ARM template deployment options, plus legacy template workflows.

### Change 1: Portal & ARM Template Option Removal
- **What:** Remove Azure Portal deployment template option (if present); remove ARM template alternatives
- **Why:** Project is IaC-focused (Terraform + Bicep); Portal/ARM templates create maintenance burden and dilute focus
- **Impact:** Cleaner scope; all deployment paths now through code (Terraform/Bicep); CI/CD bootstrap is only deployment mechanism
- **Decisions:** New Decision 14 — Portal & ARM Templates Out of Scope

### Change 2: Legacy Template Workflows Removal
- **What:** Remove any legacy/deprecated deployment workflows; consolidate to modern OIDC-based CI/CD
- **Why:** Legacy workflows create technical debt; OIDC is the modern standard; no secrets in repos
- **Impact:** `.github/workflows/` simplified; Azure DevOps pipelines modernized; only OIDC bootstrap workflows remain
- **Decisions:** New Decision 15 — CI/CD Consolidation (OIDC-Only)

## Edits Applied

**Total Edits:** 12 surgical changes

### Files Modified:
- **docs/PRD.md** — v3.1 released
  - Removed Portal deployment documentation
  - Removed ARM template references
  - Updated scope to IaC + OIDC CI/CD only
  - Removed legacy workflow sections
  
- **.github/workflows/** — Legacy workflows removed
  - Kept only OIDC-based GitHub Actions workflows
  - All ARM/Portal-based deployments removed

- **Azure DevOps Pipelines** — Modernized to OIDC
  - Removed secret-based authentication examples
  - Legacy pipeline patterns removed

## Decisions Tracked

- **Decision 14:** Portal & ARM Templates Out of Scope
  - Rationale: IaC project (Terraform + Bicep); Portal/ARM creates maintenance burden; dilutes focus
  - Implications: All deployment paths through code; users must use Terraform/Bicep; Portal is not supported deployment method
  
- **Decision 15:** CI/CD Consolidation (OIDC-Only)
  - Rationale: Modern security standard; no secrets in repos; aligns with cloud-native practices
  - Implications: Legacy password-based auth removed; OIDC is only bootstrap option; GitHub Actions + Azure DevOps both use OIDC

## Outcome

PRD v3.1 published. Portal and ARM templates removed from scope. Legacy workflows removed. CI/CD modernized to OIDC-only. Project now focused on IaC + modern CI/CD.

---

**Scope Summary After All Changes:**
- **Terraform AVM Migration** (Trinity) — Pattern module + supplemental resources
- **Bicep AVM Migration** (Tank) — Pattern module + supplemental resources
- **CI/CD Bootstrap** (Switch) — OIDC for GitHub Actions + Azure DevOps
- **Documentation/QA** (Niobe) — Migration guide + runbooks + troubleshooting
- **Project Lead** (Morpheus) — Architecture, decisions, coordination

**Deferred/Out of Scope:**
- Hub networking (ALZ IaC Accelerator)
- Portal deployments
- ARM templates
- Legacy CI/CD workflows
