<#
.SYNOPSIS
    Interactive deployment script for App Service Landing Zone Accelerator.

.DESCRIPTION
    Guides users through bootstrapping CI/CD (GitHub Actions or Azure DevOps with
    OIDC) or deploying locally via Terraform or Bicep. Supports 9 hosting scenarios
    including ASE v3, App Service Plan, and Managed Instance configurations.

.PARAMETER WhatIf
    Show what would be done without executing any commands.

.EXAMPLE
    ./deploy.ps1
    ./deploy.ps1 -WhatIf
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# ============================================================================
# Helpers
# ============================================================================

function Write-Banner {
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║     App Service Landing Zone Accelerator — Deployment       ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  This script will guide you through deploying the App Service" -ForegroundColor White
    Write-Host "  Landing Zone Accelerator using your preferred method." -ForegroundColor White
    Write-Host ""
}

function Write-Step {
    param([string]$Message)
    Write-Host "  → $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

function Write-Err {
    param([string]$Message)
    Write-Host "  ✗ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "    $Message" -ForegroundColor Gray
}

function Write-WhatIfMessage {
    param([string]$Message)
    Write-Host "  [WhatIf] $Message" -ForegroundColor Yellow
}

function Read-Choice {
    param(
        [string]$Prompt,
        [string[]]$Options,
        [string[]]$Labels
    )
    Write-Host ""
    Write-Host "  $Prompt" -ForegroundColor Cyan
    Write-Host ""
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "    [$($i + 1)] $($Labels[$i])" -ForegroundColor White
    }
    Write-Host ""
    do {
        $input_val = Read-Host "  Enter choice (1-$($Options.Count))"
        $choice = 0
        $valid = [int]::TryParse($input_val, [ref]$choice) -and $choice -ge 1 -and $choice -le $Options.Count
        if (-not $valid) {
            Write-Err "Invalid choice. Please enter a number between 1 and $($Options.Count)."
        }
    } while (-not $valid)
    return $Options[$choice - 1]
}

function Read-Input {
    param(
        [string]$Prompt,
        [string]$Default = '',
        [switch]$Secure
    )
    $displayPrompt = if ($Default) { "  $Prompt [$Default]" } else { "  $Prompt" }
    if ($Secure) {
        $secureVal = Read-Host $displayPrompt -AsSecureString
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureVal)
        $val = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        if ([string]::IsNullOrWhiteSpace($val) -and $Default) { return $Default }
        return $val
    }
    else {
        $val = Read-Host $displayPrompt
        if ([string]::IsNullOrWhiteSpace($val) -and $Default) { return $Default }
        return $val
    }
}

function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# ============================================================================
# Scenario Definitions
# ============================================================================

$Scenarios = [ordered]@{
    'managed-instance'     = 'Managed Instance'
    'ase-windows-app'      = 'ASE v3 — Windows App'
    'ase-windows-container' = 'ASE v3 — Windows Container'
    'ase-linux-app'        = 'ASE v3 — Linux App'
    'ase-linux-container'  = 'ASE v3 — Linux Container'
    'asp-windows-app'      = 'App Service Plan — Windows App'
    'asp-windows-container' = 'App Service Plan — Windows Container'
    'asp-linux-app'        = 'App Service Plan — Linux App'
    'asp-linux-container'  = 'App Service Plan — Linux Container'
}

# ============================================================================
# Prerequisites Check
# ============================================================================

function Test-Prerequisites {
    param([string]$DeployPath)

    Write-Host ""
    Write-Host "  Checking prerequisites..." -ForegroundColor Cyan
    Write-Host ""

    $allGood = $true

    # Azure CLI is always required
    if (Test-Command 'az') {
        Write-Success "Azure CLI (az) found"
    }
    else {
        Write-Err "Azure CLI (az) not found — install from https://aka.ms/installazurecli"
        $allGood = $false
    }

    # Check az login
    if ($allGood) {
        try {
            $accountJson = az account show 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw "not logged in"
            }
            $account = $accountJson | ConvertFrom-Json
            Write-Success "Logged in to Azure subscription: $($account.name) ($($account.id))"
        }
        catch {
            Write-Err "Not logged in to Azure — run 'az login' first"
            $allGood = $false
        }
    }

    # Terraform check for terraform paths
    if ($DeployPath -in @('local-terraform', 'bootstrap-github', 'bootstrap-azdo')) {
        if (Test-Command 'terraform') {
            Write-Success "Terraform found"
        }
        else {
            Write-Err "Terraform not found — install from https://www.terraform.io/downloads"
            $allGood = $false
        }
    }

    # GitHub CLI for GitHub bootstrap
    if ($DeployPath -eq 'bootstrap-github') {
        if (Test-Command 'gh') {
            Write-Success "GitHub CLI (gh) found"
        }
        else {
            Write-Err "GitHub CLI (gh) not found — install from https://cli.github.com"
            $allGood = $false
        }
    }

    # Azure DevOps CLI extension for Azure DevOps bootstrap
    if ($DeployPath -eq 'bootstrap-azdo') {
        try {
            $extensions = az extension list 2>&1 | ConvertFrom-Json
            $azdoExt = $extensions | Where-Object { $_.name -eq 'azure-devops' }
            if ($azdoExt) {
                Write-Success "Azure DevOps CLI extension found"
            }
            else {
                Write-Err "Azure DevOps CLI extension not found — run 'az extension add --name azure-devops'"
                $allGood = $false
            }
        }
        catch {
            Write-Err "Could not check Azure DevOps CLI extension"
            $allGood = $false
        }
    }

    if (-not $allGood) {
        Write-Host ""
        Write-Err "Prerequisites check failed. Please install missing tools and try again."
        exit 1
    }

    Write-Host ""
    Write-Success "All prerequisites met!"
}

# ============================================================================
# Deployment Path: Local Terraform
# ============================================================================

function Invoke-LocalTerraform {
    param(
        [string]$Scenario,
        [string]$Location,
        [string]$ResourceGroupName,
        [string]$Environment,
        [string]$WorkloadName
    )

    $repoRoot = $PSScriptRoot
    $tfDir = Join-Path $repoRoot 'infra' 'terraform'
    $exampleFile = Join-Path $tfDir 'examples' "$Scenario.tfvars"
    $targetFile = Join-Path $tfDir 'terraform.tfvars'

    if (-not (Test-Path $exampleFile)) {
        Write-Err "Example file not found: $exampleFile"
        exit 1
    }

    Write-Step "Reading example file: $Scenario.tfvars"
    $content = Get-Content $exampleFile -Raw

    # Substitute user-provided values
    $content = $content -replace 'location\s*=\s*"[^"]*"', "location          = `"$Location`""
    $content = $content -replace 'resource_group_name\s*=\s*"[^"]*"', "resource_group_name = `"$ResourceGroupName`""
    $content = $content -replace 'environment\s*=\s*"[^"]*"', "environment = `"$Environment`""

    # Update workload tag
    $content = $content -replace '(workload\s*=\s*)"[^"]*"', "`$1`"$WorkloadName`""

    if ($WhatIf) {
        Write-WhatIfMessage "Would copy $Scenario.tfvars → terraform.tfvars with substitutions:"
        Write-WhatIfMessage "  location          = `"$Location`""
        Write-WhatIfMessage "  resource_group_name = `"$ResourceGroupName`""
        Write-WhatIfMessage "  environment       = `"$Environment`""
        Write-WhatIfMessage "Would run: terraform -chdir=`"$tfDir`" init"
        Write-WhatIfMessage "Would run: terraform -chdir=`"$tfDir`" plan"
        Write-WhatIfMessage "Would prompt for confirmation, then: terraform -chdir=`"$tfDir`" apply"
        return
    }

    Write-Step "Writing terraform.tfvars"
    Set-Content -Path $targetFile -Value $content -Encoding UTF8
    Write-Success "Created: $targetFile"

    Write-Host ""
    Write-Step "Running terraform init..."
    Push-Location $tfDir
    try {
        terraform init
        if ($LASTEXITCODE -ne 0) {
            Write-Err "terraform init failed"
            exit 1
        }
        Write-Success "terraform init succeeded"

        Write-Host ""
        Write-Step "Running terraform plan..."
        terraform plan -out=tfplan
        if ($LASTEXITCODE -ne 0) {
            Write-Err "terraform plan failed"
            exit 1
        }
        Write-Success "terraform plan succeeded"

        Write-Host ""
        $confirm = Read-Input "Apply this plan? (yes/no)" -Default "no"
        if ($confirm -eq 'yes') {
            Write-Step "Running terraform apply..."
            terraform apply tfplan
            if ($LASTEXITCODE -ne 0) {
                Write-Err "terraform apply failed"
                exit 1
            }
            Write-Success "Deployment complete!"
        }
        else {
            Write-Info "Apply cancelled. The plan file is saved at: $tfDir/tfplan"
            Write-Info "Run 'terraform apply tfplan' in $tfDir to apply later."
        }
    }
    finally {
        Pop-Location
    }
}

# ============================================================================
# Deployment Path: Local Bicep
# ============================================================================

function Invoke-LocalBicep {
    param(
        [string]$Scenario,
        [string]$Location,
        [string]$ResourceGroupName,
        [string]$Environment,
        [string]$WorkloadName
    )

    $repoRoot = $PSScriptRoot
    $bicepDir = Join-Path $repoRoot 'infra' 'bicep'
    $exampleFile = Join-Path $bicepDir 'examples' "$Scenario.bicepparam"
    $targetFile = Join-Path $bicepDir "deploy-$Scenario.bicepparam"

    if (-not (Test-Path $exampleFile)) {
        Write-Err "Example file not found: $exampleFile"
        exit 1
    }

    Write-Step "Reading example file: $Scenario.bicepparam"
    $content = Get-Content $exampleFile -Raw

    # Substitute user-provided values
    $shortWorkload = $WorkloadName
    if ($shortWorkload.Length -gt 10) {
        $shortWorkload = $shortWorkload.Substring(0, 10)
        Write-Info "Workload name truncated to 10 chars for Bicep: $shortWorkload"
    }

    $content = $content -replace "param workloadName = '[^']*'", "param workloadName = '$shortWorkload'"
    $content = $content -replace "param location = '[^']*'", "param location = '$Location'"
    $content = $content -replace "param environmentName = '[^']*'", "param environmentName = '$Environment'"
    $content = $content -replace "param resourceGroupName = '[^']*'", "param resourceGroupName = '$ResourceGroupName'"

    if ($WhatIf) {
        Write-WhatIfMessage "Would copy $Scenario.bicepparam → deploy-$Scenario.bicepparam with substitutions:"
        Write-WhatIfMessage "  workloadName      = '$shortWorkload'"
        Write-WhatIfMessage "  location          = '$Location'"
        Write-WhatIfMessage "  environmentName   = '$Environment'"
        Write-WhatIfMessage "  resourceGroupName = '$ResourceGroupName'"
        Write-WhatIfMessage "Would run: az deployment sub create --location $Location --template-file $bicepDir\main.bicep --parameters $targetFile"
        return
    }

    Write-Step "Writing deploy-$Scenario.bicepparam"
    Set-Content -Path $targetFile -Value $content -Encoding UTF8
    Write-Success "Created: $targetFile"

    Write-Host ""
    Write-Step "Deploying with Bicep..."
    Write-Info "Template:   $bicepDir\main.bicep"
    Write-Info "Parameters: $targetFile"
    Write-Host ""

    $confirm = Read-Input "Proceed with deployment? (yes/no)" -Default "no"
    if ($confirm -eq 'yes') {
        $templateFile = Join-Path $bicepDir 'main.bicep'
        az deployment sub create `
            --location $Location `
            --template-file $templateFile `
            --parameters $targetFile `
            --name "deploy-$Scenario-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

        if ($LASTEXITCODE -ne 0) {
            Write-Err "Bicep deployment failed"
            exit 1
        }
        Write-Success "Deployment complete!"
    }
    else {
        Write-Info "Deployment cancelled."
        Write-Info "Run manually:"
        Write-Info "  az deployment sub create --location $Location --template-file $bicepDir\main.bicep --parameters $targetFile"
    }
}

# ============================================================================
# Deployment Path: Bootstrap GitHub Actions
# ============================================================================

function Invoke-BootstrapGitHub {
    param(
        [string]$Scenario,
        [string]$Location,
        [string]$ResourceGroupName,
        [string]$Environment,
        [string]$WorkloadName,
        [string]$OrgName
    )

    $repoRoot = $PSScriptRoot
    $bootstrapRepo = 'Azure-Samples/github-terraform-oidc-ci-cd'

    Write-Host ""
    Write-Step "Bootstrap CI/CD with GitHub Actions (OIDC)"
    Write-Host ""
    Write-Info "This will set up OIDC-based CI/CD pipelines using:"
    Write-Info "  Repository: https://github.com/$bootstrapRepo"
    Write-Info "  Scenario:   $($Scenarios[$Scenario])"
    Write-Info "  Target:     infra/terraform/ in this repo"
    Write-Host ""

    if ($WhatIf) {
        Write-WhatIfMessage "Would clone https://github.com/$bootstrapRepo"
        Write-WhatIfMessage "Would create bootstrap tfvars pointing example_repo at this repo's infra/terraform/"
        Write-WhatIfMessage "Would copy scenario values from $Scenario.tfvars"
        Write-WhatIfMessage "Would run terraform init && terraform apply in the bootstrap directory"
        return
    }

    $bootstrapDir = Join-Path $repoRoot '.bootstrap-github'

    Write-Step "Cloning bootstrap repository..."
    if (Test-Path $bootstrapDir) {
        Write-Info "Bootstrap directory already exists, pulling latest..."
        Push-Location $bootstrapDir
        git pull --quiet
        Pop-Location
    }
    else {
        git clone "https://github.com/$bootstrapRepo" $bootstrapDir --quiet
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Err "Failed to clone bootstrap repository"
        exit 1
    }
    Write-Success "Bootstrap repository ready"

    # Create bootstrap tfvars
    $bootstrapTfvars = Join-Path $bootstrapDir 'terraform.tfvars'
    $tfvarsContent = @"
# Generated by deploy.ps1 — App Service LZA Bootstrap (GitHub Actions)
# Scenario: $($Scenarios[$Scenario])

# --- Bootstrap Config ---
github_organisation_target = "$OrgName"
environment                = "$Environment"
location                   = "$Location"

# --- Points to the infra in this repo ---
example_repo              = "$($repoRoot -replace '\\', '/')/infra/terraform"

# --- Scenario-specific values from $Scenario.tfvars ---
resource_group_name       = "$ResourceGroupName"
"@

    Write-Step "Writing bootstrap terraform.tfvars"
    Set-Content -Path $bootstrapTfvars -Value $tfvarsContent -Encoding UTF8
    Write-Success "Created: $bootstrapTfvars"

    Write-Host ""
    Write-Info "Bootstrap directory: $bootstrapDir"
    Write-Info ""
    Write-Info "Next steps:"
    Write-Info "  1. cd $bootstrapDir"
    Write-Info "  2. Review terraform.tfvars"
    Write-Info "  3. terraform init"
    Write-Info "  4. terraform plan"
    Write-Info "  5. terraform apply"
    Write-Host ""

    $runNow = Read-Input "Run terraform init and plan now? (yes/no)" -Default "no"
    if ($runNow -eq 'yes') {
        Push-Location $bootstrapDir
        try {
            Write-Step "Running terraform init..."
            terraform init
            if ($LASTEXITCODE -ne 0) { Write-Err "terraform init failed"; exit 1 }
            Write-Success "terraform init succeeded"

            Write-Step "Running terraform plan..."
            terraform plan -out=tfplan
            if ($LASTEXITCODE -ne 0) { Write-Err "terraform plan failed"; exit 1 }
            Write-Success "terraform plan succeeded"

            $confirm = Read-Input "Apply this plan? (yes/no)" -Default "no"
            if ($confirm -eq 'yes') {
                terraform apply tfplan
                if ($LASTEXITCODE -ne 0) { Write-Err "terraform apply failed"; exit 1 }
                Write-Success "Bootstrap complete! GitHub Actions OIDC pipelines are configured."
            }
            else {
                Write-Info "Apply cancelled. Run 'terraform apply tfplan' in $bootstrapDir to apply later."
            }
        }
        finally {
            Pop-Location
        }
    }
}

# ============================================================================
# Deployment Path: Bootstrap Azure DevOps
# ============================================================================

function Invoke-BootstrapAzDO {
    param(
        [string]$Scenario,
        [string]$Location,
        [string]$ResourceGroupName,
        [string]$Environment,
        [string]$WorkloadName,
        [string]$OrgName
    )

    $repoRoot = $PSScriptRoot
    $bootstrapRepo = 'Azure-Samples/azure-devops-terraform-oidc-ci-cd'

    Write-Host ""
    Write-Step "Bootstrap CI/CD with Azure DevOps (OIDC)"
    Write-Host ""
    Write-Info "This will set up OIDC-based CI/CD pipelines using:"
    Write-Info "  Repository: https://github.com/$bootstrapRepo"
    Write-Info "  Scenario:   $($Scenarios[$Scenario])"
    Write-Info "  Target:     infra/terraform/ in this repo"
    Write-Host ""

    if ($WhatIf) {
        Write-WhatIfMessage "Would clone https://github.com/$bootstrapRepo"
        Write-WhatIfMessage "Would create bootstrap tfvars pointing example_repo at this repo's infra/terraform/"
        Write-WhatIfMessage "Would copy scenario values from $Scenario.tfvars"
        Write-WhatIfMessage "Would run terraform init && terraform apply in the bootstrap directory"
        return
    }

    $bootstrapDir = Join-Path $repoRoot '.bootstrap-azdo'

    Write-Step "Cloning bootstrap repository..."
    if (Test-Path $bootstrapDir) {
        Write-Info "Bootstrap directory already exists, pulling latest..."
        Push-Location $bootstrapDir
        git pull --quiet
        Pop-Location
    }
    else {
        git clone "https://github.com/$bootstrapRepo" $bootstrapDir --quiet
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Err "Failed to clone bootstrap repository"
        exit 1
    }
    Write-Success "Bootstrap repository ready"

    # Create bootstrap tfvars
    $bootstrapTfvars = Join-Path $bootstrapDir 'terraform.tfvars'
    $tfvarsContent = @"
# Generated by deploy.ps1 — App Service LZA Bootstrap (Azure DevOps)
# Scenario: $($Scenarios[$Scenario])

# --- Bootstrap Config ---
azure_devops_organisation_target = "$OrgName"
environment                      = "$Environment"
location                         = "$Location"

# --- Points to the infra in this repo ---
example_repo              = "$($repoRoot -replace '\\', '/')/infra/terraform"

# --- Scenario-specific values from $Scenario.tfvars ---
resource_group_name       = "$ResourceGroupName"
"@

    Write-Step "Writing bootstrap terraform.tfvars"
    Set-Content -Path $bootstrapTfvars -Value $tfvarsContent -Encoding UTF8
    Write-Success "Created: $bootstrapTfvars"

    Write-Host ""
    Write-Info "Bootstrap directory: $bootstrapDir"
    Write-Info ""
    Write-Info "Next steps:"
    Write-Info "  1. cd $bootstrapDir"
    Write-Info "  2. Review terraform.tfvars"
    Write-Info "  3. terraform init"
    Write-Info "  4. terraform plan"
    Write-Info "  5. terraform apply"
    Write-Host ""

    $runNow = Read-Input "Run terraform init and plan now? (yes/no)" -Default "no"
    if ($runNow -eq 'yes') {
        Push-Location $bootstrapDir
        try {
            Write-Step "Running terraform init..."
            terraform init
            if ($LASTEXITCODE -ne 0) { Write-Err "terraform init failed"; exit 1 }
            Write-Success "terraform init succeeded"

            Write-Step "Running terraform plan..."
            terraform plan -out=tfplan
            if ($LASTEXITCODE -ne 0) { Write-Err "terraform plan failed"; exit 1 }
            Write-Success "terraform plan succeeded"

            $confirm = Read-Input "Apply this plan? (yes/no)" -Default "no"
            if ($confirm -eq 'yes') {
                terraform apply tfplan
                if ($LASTEXITCODE -ne 0) { Write-Err "terraform apply failed"; exit 1 }
                Write-Success "Bootstrap complete! Azure DevOps OIDC pipelines are configured."
            }
            else {
                Write-Info "Apply cancelled. Run 'terraform apply tfplan' in $bootstrapDir to apply later."
            }
        }
        finally {
            Pop-Location
        }
    }
}

# ============================================================================
# Main Flow
# ============================================================================

function Main {
    Write-Banner

    if ($WhatIf) {
        Write-Host "  ⚠ Running in WhatIf mode — no changes will be made." -ForegroundColor Yellow
        Write-Host ""
    }

    # Step 1: Choose deployment path
    $deployPath = Read-Choice `
        -Prompt "How would you like to deploy?" `
        -Options @('bootstrap-github', 'bootstrap-azdo', 'local-terraform', 'local-bicep') `
        -Labels @(
            'Bootstrap CI/CD (GitHub Actions) — OIDC pipelines via GitHub Actions',
            'Bootstrap CI/CD (Azure DevOps)   — OIDC pipelines via Azure DevOps',
            'Deploy locally (Terraform)       — Direct terraform apply',
            'Deploy locally (Bicep)           — Direct az deployment sub create'
        )

    Write-Success "Selected: $deployPath"

    # Step 2: Prerequisites check
    Test-Prerequisites -DeployPath $deployPath

    # Step 3: Choose hosting scenario
    $scenarioKeys = @($Scenarios.Keys)
    $scenarioLabels = @($Scenarios.Values)
    $scenario = Read-Choice `
        -Prompt "Which hosting model?" `
        -Options $scenarioKeys `
        -Labels $scenarioLabels

    Write-Success "Selected: $($Scenarios[$scenario])"

    # Step 4: Gather inputs
    Write-Host ""
    Write-Host "  Configure your deployment:" -ForegroundColor Cyan
    Write-Host ""

    $location = Read-Input "Azure region (e.g. uksouth, eastus2)" -Default "uksouth"
    $environment = Read-Input "Environment name (dev/test/prod)" -Default "dev"
    $workloadName = Read-Input "Workload name (short identifier)" -Default "appsvc"
    $resourceGroupName = Read-Input "Resource group name" -Default "rg-$workloadName-$environment"

    $orgName = ''
    if ($deployPath -in @('bootstrap-github', 'bootstrap-azdo')) {
        Write-Host ""
        if ($deployPath -eq 'bootstrap-github') {
            $orgName = Read-Input "GitHub organization or username"
        }
        else {
            $orgName = Read-Input "Azure DevOps organization name"
        }
    }

    # Summary
    Write-Host ""
    Write-Host "  ┌─────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "  │  Deployment Summary                                        │" -ForegroundColor Cyan
    Write-Host "  └─────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host ""
    Write-Info "  Path:           $deployPath"
    Write-Info "  Scenario:       $($Scenarios[$scenario])"
    Write-Info "  Location:       $location"
    Write-Info "  Environment:    $environment"
    Write-Info "  Workload:       $workloadName"
    Write-Info "  Resource Group: $resourceGroupName"
    if ($orgName) {
        Write-Info "  Organization:   $orgName"
    }
    Write-Host ""

    if (-not $WhatIf) {
        $proceed = Read-Input "Proceed? (yes/no)" -Default "yes"
        if ($proceed -ne 'yes') {
            Write-Info "Cancelled."
            return
        }
    }

    # Step 5: Execute
    switch ($deployPath) {
        'local-terraform' {
            Invoke-LocalTerraform `
                -Scenario $scenario `
                -Location $location `
                -ResourceGroupName $resourceGroupName `
                -Environment $environment `
                -WorkloadName $workloadName
        }
        'local-bicep' {
            Invoke-LocalBicep `
                -Scenario $scenario `
                -Location $location `
                -ResourceGroupName $resourceGroupName `
                -Environment $environment `
                -WorkloadName $workloadName
        }
        'bootstrap-github' {
            Invoke-BootstrapGitHub `
                -Scenario $scenario `
                -Location $location `
                -ResourceGroupName $resourceGroupName `
                -Environment $environment `
                -WorkloadName $workloadName `
                -OrgName $orgName
        }
        'bootstrap-azdo' {
            Invoke-BootstrapAzDO `
                -Scenario $scenario `
                -Location $location `
                -ResourceGroupName $resourceGroupName `
                -Environment $environment `
                -WorkloadName $workloadName `
                -OrgName $orgName
        }
    }

    Write-Host ""
    Write-Host "  ════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  Done! See bootstrap/README.md for more details." -ForegroundColor Green
    Write-Host "  ════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
}

# Run
Main
