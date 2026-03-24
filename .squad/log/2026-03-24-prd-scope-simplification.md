# Session: PRD Scope Simplification

**Date:** 2026-03-24  
**Timestamp:** 2026-03-24T15:33:00Z  
**Agents:** Morpheus (Rounds 1–2)  

## Summary

Two rounds of Morpheus work addressing major scope changes requested by user.

**Round 1 (15:30):** Hub networking removed (deferred to ALZ IaC Accelerator); folder structure flattened to `infra/`. PRD v3.0 published with 25+ edits.

**Round 2 (15:33):** Portal and ARM template options removed; legacy CI/CD workflows removed; project scope simplified to IaC + OIDC CI/CD only. PRD v3.1 published with 12 edits.

## Key Decisions

- **Decision 12:** Hub Networking Deferred to ALZ IaC Accelerator
- **Decision 13:** Folder Structure Flattened to `infra/`
- **Decision 14:** Portal & ARM Templates Out of Scope
- **Decision 15:** CI/CD Consolidation (OIDC-Only)

## Scope After Changes

- Terraform AVM (pattern module) — Trinity
- Bicep AVM (pattern module) — Tank
- CI/CD Bootstrap (OIDC) — Switch
- Documentation/QA — Niobe

**Deferred:** Hub networking, Portal, ARM, legacy workflows

## Deliverables

- `.squad/orchestration-log/2026-03-24T15-30-morpheus-scope.md`
- `.squad/orchestration-log/2026-03-24T15-33-morpheus-portal.md`
- `docs/PRD.md` (v3.0 and v3.1)
- Team history files updated
