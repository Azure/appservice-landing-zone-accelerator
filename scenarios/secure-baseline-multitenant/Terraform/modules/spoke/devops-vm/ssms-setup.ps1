# This script installs SQL Server Management Studio.

function Install-SQLServerManagementStudio {
    Write-Host "Downloading SQL Server Management Studio..."

    # Creating InstallDir
    $Downloaddir = "C:\InstallDir"
    if ((Test-Path -Path $Downloaddir) -ne $true) {
        mkdir $Downloaddir
    }
    Set-Location $Downloaddir
    Start-Transcript ($Downloaddir+".\InstallPSScript.log")

    $Installer = "SSMS-Setup-ENU.exe"
    $URL = "https://aka.ms/ssmsfullsetup"
    Invoke-WebRequest $URL -OutFile $Downloaddir\$Installer

    Write-Host "Installing SQL Server Management Studio..."
    Start-Process -FilePath $Downloaddir\$Installer -Args "/install /quiet" -Verb RunAs -Wait
}

Install-SQLServerManagementStudio
