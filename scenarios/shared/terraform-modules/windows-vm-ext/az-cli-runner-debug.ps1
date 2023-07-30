param (
    [string]$command
)

Start-Transcript (".\InstallPSScript.log")
Write-Host "Received command: $command"


# Write-Host "Installing Azure CLI..."
# # Install the Azure CLI
# Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; 
# Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet';
# Remove-Item .\AzureCLI.msi
# $env:Path += ";C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\wbin\"

# # Define the list of Azure CLI commands
# # $commands = @(
# #     "az login",
# #     "az keyvault secret set --vault-name kv-appsvc-staging-337 --name mysecret --value mysecretvalue",
# #     "az appconfig kv set --auth-mode login --endpoint https://appcg-sec-baseline-staging-337.azconfig.io --key color --value red --label mylabel -y"
# # )

# # Execute each command in the list
# # foreach ($command in $commands) {
#     Write-Host "Executing command: $command"
#     Invoke-Expression $command
# # }
