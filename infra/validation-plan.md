# Validation Plan — App Service Landing Zone Accelerator

> **Owner:** Niobe (Tester / QA)
> **Status:** Draft — subject to refinement once Trinity (Terraform) and Tank (Bicep) finalize implementations
> **Scope:** `infra/terraform/` and `infra/bicep/` (spoke-only, no hub)

---

## 1. Validation Strategy Overview

Every change to IaC code must pass through four quality gates before it is considered deployable:

| Gate | What It Catches | Tools | When It Runs |
|------|----------------|-------|-------------|
| **Static Analysis** | Syntax errors, formatting, missing required fields | `terraform validate`, `terraform fmt`, `tflint`, `az bicep build`, Bicep linter | Pre-commit + CI |
| **Security Scanning** | Misconfigurations, insecure defaults, compliance violations | Trivy (replaces tfsec), PSRule for Azure | Pre-commit + CI |
| **Plan Verification** | Unexpected resource changes, drift, destructive operations | `terraform plan`, `az deployment what-if` | CI (on PR) |
| **Post-Deployment Smoke Tests** | Resources not created, DNS not resolving, app unreachable | Azure CLI checks, HTTP probes | CI (post-apply) |

---

## 2. Pre-Deployment Validation (Static Analysis)

### 2.1 Terraform

| Check | Command | Target Path | Notes |
|-------|---------|-------------|-------|
| Format | `terraform fmt -check -recursive` | `infra/terraform/` | Enforces canonical HCL formatting |
| Validate | `terraform validate` | `infra/terraform/` | Requires `terraform init` first (providers must resolve) |
| Lint | `tflint --recursive --config .tflint.hcl` | `infra/terraform/` | Checks for deprecated syntax, provider-specific issues |
| Docs | `terraform-docs` | `infra/terraform/` | Ensures README stays in sync with variables/outputs |

**tflint configuration needed:**
- Enable the `azurerm` ruleset plugin
- Enable the `terraform` ruleset (for deprecated syntax detection)
- Configure to scan `infra/terraform/` (update `.tflint.hcl` or create one at `infra/terraform/.tflint.hcl`)

### 2.2 Bicep

| Check | Command | Target Path | Notes |
|-------|---------|-------------|-------|
| Build / Validate | `az bicep build --file main.bicep` | `infra/bicep/` | Compiles Bicep → ARM; catches syntax and type errors |
| Linter | Built-in Bicep linter (runs during `az bicep build`) | `infra/bicep/` | Configured via `bicepconfig.json` |
| Parameter Validation | `az bicep build-params --file main.bicepparam` | `infra/bicep/` | Validates parameter files compile correctly |

**bicepconfig.json needed at `infra/bicep/bicepconfig.json`:**
- Enable all `warn`-level linter rules
- Promote security-relevant rules to `error` (e.g., `secure-parameter-default`, `use-secure-value-for-secure-inputs`)
- Configure module aliases for AVM registry (`br/public`)

---

## 3. Security Scanning

### 3.1 Trivy (Terraform + Bicep)

> **Note:** tfsec is now part of Trivy. The existing `.tfsec/_tfsec.yml` custom check (CUS001 — require empty backend block) should be migrated to a Trivy custom policy or Rego rule.

| Scan | Command | Target |
|------|---------|--------|
| Terraform | `trivy config --severity HIGH,CRITICAL infra/terraform/` | All `.tf` files |
| Bicep | `trivy config --severity HIGH,CRITICAL infra/bicep/` | All `.bicep` files |

**What to configure:**
- Migrate `.tfsec/_tfsec.yml` CUS001 (empty backend block) to a Trivy custom policy
- Suppress false positives via `.trivyignore` at repo root
- Severity threshold: `HIGH` and `CRITICAL` block merges; `MEDIUM` and below are advisory

### 3.2 PSRule for Azure (Bicep)

PSRule validates Bicep against Azure Well-Architected Framework rules.

**Current config (`.psrule/ps-rule.yaml`):**
```yaml
requires:
  PSRule.Rules.Azure: '>=1.29.0'
include:
  module:
  - PSRule.Rules.Azure
input:
  pathIgnore:
  - '**'
  - '!**/*.bicepparam'
configuration:
  AZURE_BICEP_FILE_EXPANSION: true
```

**Updates needed for new `infra/` structure:**
- The existing `pathIgnore` pattern (`!**/*.bicepparam`) already captures `.bicepparam` files regardless of location — no path change needed
- Verify that `AZURE_BICEP_FILE_EXPANSION: true` correctly expands the pattern module reference (`br/public:avm/ptn/...`) during analysis
- Consider adding baseline configuration to suppress rules that conflict with the pattern module's design choices (e.g., the pattern module may intentionally use certain resource configurations)
- Pin `PSRule.Rules.Azure` to a specific version (currently `>=1.29.0` — consider `>=1.35.0` for latest AVM awareness)

### 3.3 PSRule for Terraform (Optional)

PSRule can also scan Terraform plan output (exported as JSON). This gives consistent Azure WAF rule coverage across both languages:

```bash
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
# PSRule analyzes the plan JSON
```

**Decision needed:** Whether to add PSRule for Terraform or rely solely on Trivy. Recommend Trivy-only for Terraform to avoid toolchain complexity.

---

## 4. Plan Verification (Pre-Apply)

### 4.1 Terraform Plan

```bash
cd infra/terraform
terraform init
terraform plan -out=tfplan -detailed-exitcode
```

**What to verify:**
- Exit code 0 = no changes (idempotency check)
- Exit code 2 = changes present (review in PR)
- No `destroy` actions on unexpected resources
- No changes to resources outside the spoke resource group
- Plan output saved as artifact for audit trail

**Pattern module–specific checks:**
- Verify the pattern module produces expected resource types (App Service Plan, Web App, VNet, Key Vault, etc.)
- Confirm supplemental resources (SQL, Redis, App Config, OpenAI, VM) are planned correctly
- Validate private endpoint and DNS zone associations
- Check that hub integration parameters (hub VNet ID, route table ID) are wired correctly

### 4.2 Bicep What-If

```bash
az deployment sub what-if \
  --location <location> \
  --template-file infra/bicep/main.bicep \
  --parameters infra/bicep/main.bicepparam
```

**What to verify:**
- No unexpected `Delete` operations
- All expected resources appear as `Create` or `NoChange`
- Resource group placement is correct (spoke RG, not hub RG)
- Deployment Stack compatibility: `az stack sub create --what-if` if using Deployment Stacks

---

## 5. Post-Deployment Smoke Tests

These run after a successful `terraform apply` or `az deployment sub create` in CI.

### 5.1 Resource Existence Checks

```bash
# Verify core resources exist
az resource list --resource-group $SPOKE_RG --query "[].{name:name, type:type}" -o table

# Expected resources (minimum):
# - Microsoft.Web/serverfarms (App Service Plan)
# - Microsoft.Web/sites (Web App)
# - Microsoft.Network/virtualNetworks (VNet)
# - Microsoft.KeyVault/vaults (Key Vault)
# - Microsoft.Insights/components (App Insights)
# - Microsoft.OperationalInsights/workspaces (Log Analytics)
# - Microsoft.ContainerRegistry/registries (ACR)
# - Microsoft.Storage/storageAccounts (Storage)
```

### 5.2 Private Endpoint and DNS Resolution

```bash
# Verify private endpoints are provisioned
az network private-endpoint list --resource-group $SPOKE_RG -o table

# Verify private DNS zones exist and have records
az network private-dns zone list --resource-group $SPOKE_RG -o table

# Test DNS resolution from within the VNet (requires jump host or Az CLI with VNet integration)
# nslookup <webapp-name>.azurewebsites.net  → should resolve to private IP
# nslookup <keyvault-name>.vault.azure.net  → should resolve to private IP
```

### 5.3 App Reachability

```bash
# If Front Door / App Gateway is configured:
curl -s -o /dev/null -w "%{http_code}" https://<frontdoor-endpoint>.azurefd.net/
# Expected: 200 or 403 (if WAF blocks unauthenticated)

# Web App health check (via Kudu or SCM):
az webapp show --name <webapp-name> --resource-group $SPOKE_RG --query "state" -o tsv
# Expected: "Running"
```

### 5.4 Sample App Deployment Verification

```bash
# After deploying the sample app:
az webapp deployment list-publishing-profiles --name <webapp-name> --resource-group $SPOKE_RG -o table
# Verify deployment slots exist if configured
az webapp deployment slot list --name <webapp-name> --resource-group $SPOKE_RG -o table
```

### 5.5 Supplemental Resource Checks

```bash
# SQL Server connectivity
az sql server list --resource-group $SPOKE_RG --query "[].fullyQualifiedDomainName" -o tsv

# Redis availability
az redis show --name <redis-name> --resource-group $SPOKE_RG --query "provisioningState" -o tsv
# Expected: "Succeeded"

# App Configuration
az appconfig show --name <appconfig-name> --resource-group $SPOKE_RG --query "provisioningState" -o tsv
# Expected: "Succeeded"
```

---

## 6. Pattern Module–Specific Validation

The AVM pattern modules are the core of the new architecture. They require targeted validation:

### 6.1 Terraform Pattern Module (`Azure/avm-ptn-app-service-landing-zone/azure`)

| What to Validate | How | Pass Criteria |
|-----------------|-----|---------------|
| Module resolves from registry | `terraform init` succeeds | No registry auth or version errors |
| Required variables are documented | `terraform-docs` output matches README | All required inputs listed |
| Default values are secure | Trivy scan + manual review | No public endpoints by default; encryption at rest enabled |
| Outputs include expected values | `terraform output` after apply | VNet ID, subnet IDs, Key Vault ID, App Service hostname all present |
| Idempotent apply | Two consecutive `terraform apply` | Second apply reports 0 changes |
| Spoke-only (no hub resources created) | `terraform state list` | No hub VNet, Firewall, or Bastion resources in state |
| Hub integration parameters accepted | `terraform plan` with hub VNet ID | Plan shows peering resource to hub |

### 6.2 Bicep Pattern Module (`br/public:avm/ptn/app-service-lza/hosting-environment`)

| What to Validate | How | Pass Criteria |
|-----------------|-----|---------------|
| Module resolves from registry | `az bicep build` succeeds | No registry or version errors |
| Parameters documented | Parameter file compiles | All required params present in `.bicepparam` |
| Default values are secure | PSRule scan | No Azure WAF violations on defaults |
| Outputs include expected values | `az deployment sub show` | Resource IDs for VNet, Key Vault, App Service, etc. |
| Deployment Stack compatible | `az stack sub create` | Stack creation succeeds; resources tracked |
| Spoke-only (no hub resources) | Deployment output resource list | No hub networking resources |
| Hub integration parameters accepted | What-if with hub params | Peering planned to provided hub VNet |

---

## 7. Pre-Commit Hooks

The `.pre-commit-config.yaml` must be updated to cover the new `infra/` paths. See the updated config committed alongside this plan.

**Hooks for `infra/terraform/`:**
- `terraform_fmt` — format check
- `terraform_validate` — syntax validation
- `terraform_docs` — README sync
- `terraform_tflint` — linting

**Hooks for `infra/bicep/`:**
- Custom hook: `az bicep build` on changed `.bicep` files
- PSRule: Run on changed `.bicepparam` files

**Security scanning (both):**
- Trivy: Run on all changed IaC files

---

## 8. Existing Config Assessment

### `.tfsec/_tfsec.yml` — Needs Migration

The current custom check (CUS001: require empty `backend "azurerm" {}` block) is still relevant for `infra/terraform/`. However:
- **tfsec is deprecated** in favor of Trivy's built-in misconfiguration scanner
- **Action:** Migrate CUS001 to a Trivy custom Rego policy or `.trivyignore`-based workflow
- **Interim:** tfsec still works; keep it until Trivy migration is complete

### `.psrule/ps-rule.yaml` — Minor Updates

- Path patterns already use globs that will match `infra/bicep/**/*.bicepparam` ✅
- Version pin should be updated (`>=1.29.0` → pin to latest stable)
- May need baseline suppressions for pattern module design choices
- Verify `AZURE_BICEP_FILE_EXPANSION: true` works with registry-referenced pattern modules

### `.pre-commit-config.yaml` — Needs Update

- Current config only covers Terraform (`terraform_fmt`, `terraform_docs`)
- `terraform_validate` is commented out (was broken by OpenAI module) — re-enable for `infra/terraform/`
- Add Bicep hooks
- Add Trivy hooks
- See updated file for details

---

## 9. CI/CD Integration Notes

> CI/CD pipelines are owned by Switch and come from the OIDC bootstrap repos. This section documents what validation steps those pipelines should include.

**PR Validation Pipeline (runs on every PR touching `infra/`):**
1. `terraform fmt -check` / `az bicep build` (static analysis)
2. `tflint` / Bicep linter (linting)
3. `trivy config` (security scanning)
4. `PSRule` for `.bicepparam` files (Azure WAF compliance)
5. `terraform plan -detailed-exitcode` / `az deployment sub what-if` (plan verification)

**Post-Apply Pipeline (runs after merge to main, per environment):**
1. `terraform apply` / `az deployment sub create` (deployment)
2. Smoke tests from Section 5 (resource existence, DNS, app health)
3. Sample app deployment + health check

**Environment Progression:**
- `dev` → automatic apply + smoke tests
- `test` → manual approval gate → apply + smoke tests
- `prod` → manual approval gate → apply + smoke tests + extended validation

---

## 10. Open Questions

1. **Pattern module maturity:** Bicep pattern module is v0.2. How do we handle breaking changes in minor versions? → Pin versions; test upgrades in dev first.
2. **PSRule + pattern module:** Does PSRule correctly expand `br/public:` registry references? → Needs testing once Bicep implementation exists.
3. **Trivy Bicep support:** Trivy's Bicep scanning is newer than its Terraform support. Verify coverage against our `.bicep` files.
4. **State migration validation:** How do we test `terraform state mv` in CI without a real environment? → Use a dedicated test subscription or mock state file.
5. **Smoke test identity:** Post-deployment smoke tests need Azure CLI auth. This will use the same OIDC identity as the deployment pipeline.

---

## Appendix: Tool Versions

| Tool | Minimum Version | Notes |
|------|----------------|-------|
| Terraform | >= 1.9 | Required by AVM pattern module |
| AzureRM Provider | ~> 4.0 | Required by AVM pattern module |
| Bicep CLI | Latest | Use `az bicep upgrade` |
| tflint | >= 0.50.0 | With azurerm plugin |
| Trivy | >= 0.50.0 | Replaces tfsec |
| PSRule.Rules.Azure | >= 1.35.0 | For latest AVM rule coverage |
| pre-commit | >= 3.0 | Hook framework |
