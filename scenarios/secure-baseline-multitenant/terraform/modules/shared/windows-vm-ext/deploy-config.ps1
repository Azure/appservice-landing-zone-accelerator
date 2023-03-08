param (
    [string]$keyVaultName,
    [string]$secretName,
    [string]$secretValue
)

# Install the Azure CLI
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -ArgumentList /i, .\AzureCLI.msi /quiet -Wait
Remove-Item .\AzureCLI.msi

# Authenticate with Azure using the Managed Identity
az login --identity

# Add the secret to the Key Vault
az keyvault secret set --vault-name $keyVaultName --name $secretName --value $secretValue