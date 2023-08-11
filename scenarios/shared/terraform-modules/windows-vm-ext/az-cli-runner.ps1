param (
    [Parameter(Mandatory = $true)]
    [string]$command
)

$Downloaddir = "D:\ac-cli-runner"
if ((Test-Path -Path $Downloaddir) -ne $true) {
    mkdir $Downloaddir
}

$date = Get-Date -Format "yyyyMMdd-HHmmss"
Start-Transcript ("D:\ac-cli-runner\InstallPSScript-" + $date + ".log")

Write-Host "Installing Azure CLI..."
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile D:\ac-cli-runner\AzureCLI.msi; 
Start-Process msiexec.exe -Wait -ArgumentList '/I D:\ac-cli-runner\AzureCLI.msi /quiet';
$env:Path += ";C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\wbin\"


Write-Host "Executing command: $command"
Invoke-Expression $command