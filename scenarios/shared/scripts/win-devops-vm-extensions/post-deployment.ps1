<#
.SYNOPSIS 
    This script is used to install and configure the following tools on a Windows VM:
        - Azure CLI
        - Sql Server Management Studio (SSMS)
        - Github Actions Runner
        - Azure DevOps Agent

.PARAMETER az_cli_commands
    A string containing the commands to run after installing the Azure CLI. 
    This parameter is optional. If not provided, the Azure CLI will not be installed.

.PARAMETER github_repository
    The URL of the Github repository to use for the Github Actions Runner. 
    This parameter is optional. If not provided, the Github Actions Runner will not be installed.
    If this parameter is provided, then github_token must also be provided.

.PARAMETER github_token
    The token to use for the Github Actions Runner. 
    This parameter is optional. If not provided, the Github Actions Runner will not be installed.
    If this parameter is provided, then github_repository must also be provided.

.PARAMETER ado_organization
    The URL of the Azure DevOps organization to use for the Azure DevOps Agent. 
    This parameter is optional. If not provided, the Azure DevOps Agent will not be installed.
    If this parameter is provided, then ado_token must also be provided.

.PARAMETER ado_token
    The PAT token to use for the Azure DevOps Agent. 
    This parameter is optional. If not provided, the Azure DevOps Agent will not be installed.
    If this parameter is provided, then ado_organization must also be provided.

.PARAMETER install_ssms
    A switch to indicate whether or not to install Sql Server Management Studio (SSMS). 
    This parameter is optional. If not provided, SSMS will not be installed.
#>
param (
    [Parameter(Mandatory = $false)]
    [string]$az_cli_commands,

    [Parameter(Mandatory = $false)]
    [string]$github_repository,

    [Parameter(Mandatory = $false)]
    [string]$github_token,

    [Parameter(Mandatory = $false)]
    [string]$ado_organization,

    [Parameter(Mandatory = $false)]
    [string]$ado_token,

    [switch]
    $install_ssms = $false
)

#Validate parameters
if (-not [string]::IsNullOrEmpty($github_token) -and [string]::IsNullOrEmpty($github_repository)) {
    throw "If github_token is provided, then github_repository must also be provided."
}
if (-not [string]::IsNullOrEmpty($github_repository) -and [string]::IsNullOrEmpty($github_token)) {
    throw "If github_repository is provided, then github_token must also be provided."
}
if (-not [string]::IsNullOrEmpty($ado_organization) -and [string]::IsNullOrEmpty($ado_token)) {
    throw "If ado_organization is provided, then ado_token must also be provided."
}
if (-not [string]::IsNullOrEmpty($ado_token) -and [string]::IsNullOrEmpty($ado_organization)) {
    throw "If ado_token is provided, then ado_organization must also be provided."
}

$basePath = "D:"
$logsFolder = "$($basePath)\post-deployment-extension\"
if ((Test-Path -Path $logsFolder) -ne $true) {
    mkdir $logsFolder
}

$date = Get-Date -Format "yyyyMMdd-HHmmss"
Start-Transcript ($logsFolder + "post-deployment-script" + $date + ".log")

$downloads = @()

# if (-not [string]::IsNullOrEmpty($az_cli_commands)) {
# install azure CLI
$azCliInstallPath = "C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\wbin"

$downloads += @{
    name            = "Azure CLI"
    url             = "https://aka.ms/installazurecliwindows"
    path            = "$($basePath)\ac-cli-runner\"
    file            = "AzureCLI.msi"
    installCmd      = "Start-Process msiexec.exe -Wait -ArgumentList '/I D:\ac-cli-runner\AzureCLI.msi /quiet'"
    testInstallPath = "$($azCliInstallPath)\az.cmd"
    postInstallCmd  = $az_cli_commands 
}

$env:Path += ";C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\wbin\"
# }


if ($install_ssms) {
    $ssmsInstallPath = "C:\Program Files (x86)\Microsoft SQL Server Management Studio 19"

    $downloads += @{
        name            = "Sql Server Management Studio (SSMS)"
        url             = "https://aka.ms/ssmsfullsetup"
        path            = "$($basePath)\sql-server-mgmt-studio\"
        file            = "SSMS-Setup-ENU.exe"
        installCmd      = "Start-Process -FilePath '$($basePath)\sql-server-mgmt-studio\SSMS-Setup-ENU.exe' -Args '/install /quiet' -Verb RunAs -Wait"
        testInstallPath = "$($ssmsInstallPath)\Common7\IDE\Ssms.exe"
        postInstallCmd  = ""
    }
}

if (-not [string]::isNullorEmpty($github_repository) -and -not [string]::isNullorEmpty($github_token)) {
    $ghInstallPath = "C:\github-actions"
    $ghZipPath = "$($basePath)\github-actions\actions-runner-win-x64-2.303.0.zip"
    
    $downloads += @{
        name            = "Github Actions Runner"
        url             = "https://github.com/actions/runner/releases/download/v2.303.0/actions-runner-win-x64-2.303.0.zip"
        path            = "$($basePath)\github-actions\"
        file            = "actions-runner-win-x64-2.303.0.zip"
        installCmd      = "Add-Type -AssemblyName System.IO.Compression.FileSystem; " +
        "[System.IO.Compression.ZipFile]::ExtractToDirectory(`"$($ghZipPath)`", `"$($ghInstallPath)`");"
        testInstallPath = "$($ghInstallPath)\bin\Runner.Listener.exe"
        postInstallCmd  = "$($ghInstallPath)\config.cmd --url $($github_repository) --token $($github_token) --unattended --replace --runasservice;"
    }
}

if (-not [string]::isNullorEmpty($ado_organization) -and -not [string]::isNullorEmpty($ado_token)) {
    $adoInstallPath = "C:\azure-devops-agent"
    $adoZipPath = "$($basePath)\azure-devops-agent\vsts-agent-win-x64-3.220.2.zip"
    
    $downloads += @{
        name            = "Azure DevOps Agent"
        url             = "https://vstsagentpackage.azureedge.net/agent/3.220.2/vsts-agent-win-x64-3.220.2.zip"
        path            = "$($basePath)\azure-devops-agent\"
        file            = "vsts-agent-win-x64-3.220.2.zip"
        installCmd      = "Add-Type -AssemblyName System.IO.Compression.FileSystem; " +
        "[System.IO.Compression.ZipFile]::ExtractToDirectory(`"$($adoZipPath)`", `"$($adoInstallPath)`");"
        testInstallPath = "$($adoInstallPath)\bin\Agent.Listener.exe"
        postInstallCmd  = "$($adoInstallPath)\config.cmd --url $($ado_organization) --auth pat --token $($ado_token) --unattended --replace --runasservice;"
    }
}

$downloadJob = {
    param($url, $filePath)

    Invoke-WebRequest -Uri $url -OutFile $filePath
    Write-Host "Download from $($url) completed!"
}

$jobs = @()
foreach ($download in $downloads) {

    $filePath = $download.path + $download.file

    if ((Test-Path -Path $download.path) -ne $true) {
        mkdir $download.path | Out-Null
    }

    Write-Host "Checking if file is already present: $filePath"
    if ((Test-Path -Path $filePath) -eq $true) {
        Write-Host "File already exists, skipping download."
        continue
    }

    Write-Host "File not present, downloading from: $($download.url)"
    $job = Start-Job -Name $download.name -ScriptBlock $downloadJob -ArgumentList $download.url, $filePath
    $jobs += $job
}

# Wait for all downloads to complete
if ($jobs.Count -gt 0) {
    while ($jobs | Where-Object { $_.State -eq 'Running' }) {
        Start-Sleep -Seconds 5
        Write-Host "Installers are still downloading:"
        $jobs | Format-Table -Property Name, State
    }

    # Get the output from each job and add it to an array
    $output = $jobs | Receive-Job | Sort-Object

    # Display the output
    Write-Host $output
}

foreach ($download in $downloads) {
    $filePath = $download.path + $download.file

    Write-Host "Checking if $($download.name) is already installed in $($download.testInstallPath)."
    if ((Test-Path -Path $download.testInstallPath) -eq $true) {
        Write-Host "$($download.name) is already installed, skipping install."
        continue
    }

    Write-Host "Running install command: $($download.installCmd)"
    Invoke-Expression $download.installCmd
}

foreach ($download in $downloads) {
    if (-not [string]::IsNullOrEmpty($download.postInstallCmd)) {
        Write-Host "Running post install command: $($download.postInstallCmd)"
        Invoke-Expression $download.postInstallCmd
        Write-Host "Post install command completed: $($download.postInstallCmd)"
    }
}


##############################################################################################################
# get latest git 32-bit exe 
Write-Host "Download and Install latest Git 32-bit"

$pattern = 'https:\/\/github\.com\/git-for-windows\/git\/releases\/download\/v\d+\.\d+\.\d+\.windows\.\d+\/Git-\d+\.\d+\.\d+-32-bit\.exe'
$URL = "https://api.github.com/repos/git-for-windows/git/releases"

$URL = (Invoke-WebRequest -Uri $URL -UseBasicParsing).Content | ConvertFrom-Json 
Write-Host "got the json content"

# hmm when chained together it doesn't work
$URL = $URL | Select-Object -ExpandProperty "assets" |
Where-Object "browser_download_url" -Match $pattern |
Select-Object -ExpandProperty "browser_download_url"

Write-Host "got the URLs. Downloading from $($URL[0])"
# download
Invoke-WebRequest -Uri $URL[0] -OutFile "git-latest-32-bit.exe"

Write-Host "Downloaded. Installing..."

# Install Git
Start-Process -FilePath "git-latest-32-bit.exe" -ArgumentList "/SILENT" -Wait

Write-Host "Installed Git. Removing the downloaded installer"

# Remove the downloaded Git installer
Remove-Item -Path "git-latest-32-bit.exe"

# ##############################################################################################################
# # # get latest download url for winget-cli
# # get latest download url
# $URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
# $URL = (Invoke-WebRequest -Uri $URL -UseBasicParsing).Content | ConvertFrom-Json |
# Select-Object -ExpandProperty "assets" |
# Where-Object "browser_download_url" -Match '.msixbundle' |
# Select-Object -ExpandProperty "browser_download_url"

# # download
# Invoke-WebRequest -Uri $URL -OutFile "Setup.msix" -UseBasicParsing

# # install
# Add-AppxPackage -Path "Setup.msix"

# # delete file
# Remove-Item "Setup.msix"
# Write-Host "Installing winget finished!"

# # # Run Azure CLI commands

# # if (-not [string]::IsNullOrEmpty($az_cli_commands)) {
# #     Write-Host "Running Azure CLI commands: $($az_cli_commands)"
# #     Invoke-Expression $az_cli_commands
# # }

# # # Run Github Actions Runner commands


##############################################################################################################
# install azure developer CLI AZD
Write-Host "Install Azure Developer CLI AZD"
Invoke-RestMethod 'https://aka.ms/install-azd.ps1' -OutFile 'install-azd.ps1'
./install-azd.ps1
# # delete file
# Remove-Item "install-azd.ps1" 


# # Basic Dev Utilities Section
# Write-Host "Install Git"
# $wingetInstallResult = Start-Process -FilePath "winget" -ArgumentList "install --id=Git.Git --accept-package-agreements --accept-source-agreements" -Wait -NoNewWindow

# if ($wingetInstallResult.ExitCode -eq 0) {
#     Write-Host "Git installed successfully."
# }
# else {
#     Write-Host "Error installing Git"
# }
# Write-Host "* * * * * * * * * *"

# # Install Microsoft.AzureCLI
# Write-Host "Install Microsoft.AzureCLI"
# $azureCliInstallResult = Start-Process -FilePath "winget" -ArgumentList "install --id=Microsoft.AzureCLI --accept-package-agreements --accept-source-agreements" -Wait -NoNewWindow

# if ($azureCliInstallResult.ExitCode -eq 0) {
#     Write-Host "Microsoft.AzureCLI installed successfully."
# }
# else {
#     Write-Host "Error installing Microsoft.AzureCLI!!!"
# }
# Write-Host "* * * * * * * * * *"

# # Install Microsoft.Bicep
# Write-Host "Install Microsoft.Bicep"
# $bicepInstallResult = Start-Process -FilePath "winget" -ArgumentList "install --id=Microsoft.Bicep --accept-package-agreements --accept-source-agreements" -Wait -NoNewWindow

# if ($bicepInstallResult.ExitCode -eq 0) {
#     Write-Host "Microsoft.Bicep installed successfully."
# }
# else {
#     Write-Host "Error installing Microsoft.Bicep!!!"
# }
# Write-Host "* * * * * * * * * *"

# # Install Microsoft.Azd
# Write-Host "Install Microsoft.Azd"
# $bicepInstallResult = Start-Process -FilePath "winget" -ArgumentList "install --id=Microsoft.Azd --accept-package-agreements --accept-source-agreements" -Wait -NoNewWindow

# if ($bicepInstallResult.ExitCode -eq 0) {
#     Write-Host "Microsoft.Azd installed successfully."
# }
# else {
#     Write-Host "Error installing Microsoft.Azd!!!"
# }
# Write-Host "* * * * * * * * * *"
