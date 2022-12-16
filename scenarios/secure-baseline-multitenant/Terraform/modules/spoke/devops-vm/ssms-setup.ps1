# This script installs SQL Server Management Studio.

function Install-SQLServerManagementStudio {
    Write-Host "Downloading SQL Server Management Studio..."
    $Path = $env:TEMP
    $Installer = "SSMS-Setup-ENU.exe"
    $URL = "https://aka.ms/ssmsfullsetup"
    Invoke-WebRequest $URL -OutFile $Path\$Installer

    Write-Host "Installing SQL Server Management Studio..."
    Start-Process -FilePath $Path\$Installer -Args "/install /quiet" -Verb RunAs -Wait
    Remove-Item $Path\$Installer
}

Install-SQLServerManagementStudio
