<#
.SYNOPSIS 
    This script is used to install and configure the following tools on a Windows VM:
        - Azure CLI, Azure Developer CLI (AZD), and Git
        - Sql Server Management Studio (SSMS)
        - Github Actions Runner
        - Azure DevOps Agent

.PARAMETER az_cli_commands
    A string containing the commands to run after installing the Azure CLI. 
    This parameter is optional. If not provided, the Azure CLI will not be installed. unless install_clis is set to true.

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

.PARAMETER install_clis
    A switch to indicate whether or not to install the Azure CLI, AZD CLI and git. 
    This parameter is optional. If not provided, the Azure CLI, AZD CLI and git will not be installed.

.PARAMETER install_java_tools
    A switch to indicate whether or not to install the Java tools.Maven is included 
    This parameter is optional. If not provided, the Java tools will not be installed.

.PARAMETER install_python_tools
    A switch to indicate whether or not to install the Python tools. 
    This parameter is optional. If not provided, the Python tools will not be installed.

.PARAMETER install_node_tools 
    A switch to indicate whether or not to install the Node tools. 
    This parameter is optional. If not provided, the Node tools will not be installed.

.PARAMETER install_pwsh_tools 
    A switch to indicate whether or not to install the cross platform Power Shell based on .net core. 
    This parameter is optional. If not provided, the PowerShell will not be installed.
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
    $install_ssms = $false,

    [switch]
    $install_clis = $false,

    [switch]
    $install_java_tools = $false,

    [switch]
    $install_python_tools = $false,

    [switch]
    $install_node_tools = $false,

    [switch]
    $install_pwsh_tools  = $false
)

Write-Host "script started"

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

##############################################################################################################
if (-not [string]::IsNullOrEmpty($az_cli_commands) -or $install_clis) {
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
}

##############################################################################################################
## install azure developer CLI AZD
if ($install_clis) {
    $azdInstallPath = "$($env:LOCALAPPDATA)\Programs\Azure Dev CLI"

    $downloads += @{
        name            = "AZD CLI"
        url             = "https://azure-dev.azureedge.net/azd/standalone/release/latest/azd-windows-amd64.msi"
        path            = "$($basePath)\azd\"
        file            = "azd-windows-amd64.msi"
        installCmd      = "Start-Process msiexec.exe -Wait -ArgumentList '/i D:\azd\azd-windows-amd64.msi /qn /quiet'"
        testInstallPath = "$($azdInstallPath)\azd.exe"
        postInstallCmd  = "" 
    }

    $env:Path += ";$($azdInstallPath)\"
}

##############################################################################################################
## install Java
if ($install_java_tools) {
    $javaInstallPath = "C:\Program Files\Java\jdk-17"

    $downloads += @{
        name            = "Java JDK 17"
        url             = "https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.msi"
        path            = "$($basePath)\java\"
        file            = "jdk-17_windows-x64_bin.msi"
        installCmd      = "Start-Process msiexec.exe -Wait -ArgumentList '/i D:\java\jdk-17_windows-x64_bin.msi /qn /quiet'"
        testInstallPath = "$($javaInstallPath)\bin\java.exe"
        postInstallCmd  = "" 
    }

    $env:Path += ";$($javaInstallPath)\bin\"
    [Environment]::SetEnvironmentVariable("JAVA_HOME", "$($javaInstallPath)", "Machine")

    # install maven
    $mavenInstallPath = "C:\Program Files\apache-maven-3.9.5"
    
    $downloads += @{
        name            = "Maven 3.9.5"
        url             = "https://dlcdn.apache.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.zip"
        path            = "$($basePath)\maven\"
        file            = "apache-maven-3.9.5-bin.zip"
        installCmd      = "Add-Type -AssemblyName System.IO.Compression.FileSystem; " +
        "[System.IO.Compression.ZipFile]::ExtractToDirectory(`"$($basePath)\maven\apache-maven-3.9.5-bin.zip`", `"C:\Program Files\`");"
        testInstallPath = "$($mavenInstallPath)\bin\mvn.cmd"
        postInstallCmd  = "" 
    }

    

    $env:Path += ";$($mavenInstallPath)\bin\"
}

##############################################################################################################
## install Node.js
if ($install_node_tools) {
    $nodeInstallPath = "C:\Program Files\nodejs"

    $downloads += @{
        name            = "Node.js"
        url             = "https://nodejs.org/dist/v20.9.0/node-v20.9.0-x64.msi"
        path            = "$($basePath)\nodejs\"
        file            = "node-v20.9.0-x64.msi"
        installCmd      = "Start-Process msiexec.exe -Wait -ArgumentList '/i D:\nodejs\node-v20.9.0-x64.msi /qn /quiet'"
        testInstallPath = "$($nodeInstallPath)\node.exe"
        postInstallCmd  = "" 
    }

    $env:Path += ";$($nodeInstallPath)\"
}

##############################################################################################################
## install Power Shell
if ($install_pwsh_tools ) {
    $pwshInstallPath = "C:\Program Files\PowerShell"

    $downloads += @{
        name            = "Power Shell"
        url             = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/PowerShell-7.4.0-win-x64.msi"
        path            = "$($basePath)\powershell\"
        file            = "PowerShell-7.4.0-win-x64.msi"
        installCmd      = "Start-Process msiexec.exe -Wait -ArgumentList '/i D:\powershell\PowerShell-7.4.0-win-x64.msi /qn /quiet'"
        testInstallPath = "$($pwshInstallPath)\7\pwsh.exe"
        postInstallCmd  = "" 
    }

    $env:Path += ";$($pwshInstallPath)\7\"
}

##############################################################################################################
# install the latest 64-bit Git
if ($install_clis) {
    $pattern = 'https:\/\/github\.com\/git-for-windows\/git\/releases\/download\/v\d+\.\d+\.\d+\.windows\.\d+\/Git-\d+\.\d+\.\d+-64-bit\.exe'
    $URL = "https://api.github.com/repos/git-for-windows/git/releases"

    $URL = (Invoke-WebRequest -Uri $URL -UseBasicParsing).Content | ConvertFrom-Json 
    Write-Host "got the json content"

    # hmm when chained together it doesn't work
    $URL = $URL | Select-Object -ExpandProperty "assets" |
    Where-Object "browser_download_url" -Match $pattern |
    Select-Object -ExpandProperty "browser_download_url"

    # https://github.com/git-for-windows/git/releases/download/v2.40.1.windows.1/Git-2.40.1-64-bit.exe
    # Start-Process -FilePath "git-latest-64-bit.exe" -ArgumentList "/SILENT" -Wait
    Write-Host "got the URLs to Download from $($URL[0])"
    $gitInstallPath = "C:\Program Files\Git\bin"
}

$downloads += @{
    name            = "Git 64bit"
    url             = "$($URL[0])"
    path            = "$($basePath)\git\"
    file            = "git-latest-64-bit.exe"
    installCmd      = "Start-Process -Wait -FilePath D:\git\git-latest-64-bit.exe -ArgumentList '/verysilent /norestart /suppressmsgboxes'"
    testInstallPath = "$($gitInstallPath)\git.exe"
    postInstallCmd  = "" 
}

##############################################################################################################
## install Python
if ($install_python_tools) {
    $pythonInstallPath = "C:\Program Files\Python311\"

    $downloads += @{
        name            = "Python 3.11.6"
        url             = "https://www.python.org/ftp/python/3.11.6/python-3.11.6-amd64.exe"
        path            = "$($basePath)\python\"
        file            = "python-3.11.6-amd64.exe"
        installCmd      = "Start-Process -Wait -FilePath D:\python\python-3.11.6-amd64.exe -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1'"
        testInstallPath = "$($pythonInstallPath)\python.exe"
        postInstallCmd  = ""
    }


}

##############################################################################################################
# install the SSMS
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

##############################################################################################################
# install the guthub actions runner
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

##############################################################################################################
# install the azure devops agent
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

Write-Host "All done!"