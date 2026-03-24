# Morpheus Round 1: Scope Changes (Hub Networking Removal + Folder Flattening)

**Timestamp:** 2026-03-24T15:30:00Z  
**Agent:** Morpheus (Lead/Architect)  
**Mode:** background  
**Status:** Complete

## Work Summary

User requested significant scope changes to the App Service Landing Zone Accelerator refactoring project:

### Change 1: Hub Networking Removal (Deferred to ALZ IaC Accelerator)
- **What:** Remove all hub networking infrastructure (hub spoke model, hub resources, hub configuration)
- **Why:** Hub networking is more appropriately handled by the Azure Landing Zones IaC Accelerator; keep this project focused on App Service Landing Zone specifics
- **Impact:** Simplifies Terraform spoke model (hub-spoke split in `scenarios/secure-baseline-multitenant/terraform/` can be removed); no hub state management
- **Decisions:** New Decision 12 — Hub Networking Deferred to ALZ IaC Accelerator

### Change 2: Folder Structure Flattening (infra/)
- **What:** Flatten nested folder structure: `scenarios/secure-baseline-multitenant/terraform/` → `infra/`; `scenarios/shared/terraform-modules/` → `infra/modules/`
- **Why:** Flatter structure improves discoverability, reduces cognitive load, aligns with modern IaC repo conventions
- **Impact:** All references to nested paths updated; documentation updated; clearer module organization
- **Decisions:** New Decision 13 — Folder Structure Flattened to infra/

## Edits Applied

**Total Edits:** 25+ surgical changes

### Files Modified:
- **docs/PRD.md** — v3.0 released
  - Updated folder structure references throughout
  - Removed hub networking sections
  - Updated scope/goals to reflect deferred hub work
  - Updated timelines (hub removal reduces scope)
  
- **README.md** — Updated to reflect new folder structure
- **docs/** — Architecture docs updated for infra/ folder naming

## Decisions Tracked

- **Decision 12:** Hub Networking Deferred to ALZ IaC Accelerator
  - Rationale: Hub is complex, better handled by ALZ IaC Accelerator; this project focused on App Service
  - Implications: Spoke-only model; state management simplified; ALZ IaC Accelerator integration point documented
  
- **Decision 13:** Folder Structure Flattened to infra/
  - Rationale: Flatter structure improves UX; aligns with industry conventions
  - Implications: All folder references updated; module paths simplified; clearer hierarchy (infra/modules/, infra/bootstrap/)

## Outcome

PRD v3.0 published. Hub networking removed from scope. Folder structure flattened to `infra/`. Team updated with new structure and deferred scope.

---

**Next Steps:**
- Morpheus Round 2: Portal/ARM removal + legacy workflow removal
- Team implements updated structure
