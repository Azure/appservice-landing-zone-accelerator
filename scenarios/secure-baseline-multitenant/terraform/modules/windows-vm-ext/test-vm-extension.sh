# /bin/bash

commandToExecute='powershell.exe -ExecutionPolicy Unrestricted -File post-deployment.ps1 -az_cli_commands "az version" -install_ssms'
fileUris="'https://raw.githubusercontent.com/Azure/appservice-landing-zone-accelerator/main/scenarios/shared/scripts/win-devops-vm-extensions/post-deployment.ps1'"
protectedSettings='{"fileUris": "['$fileUris']", "commandToExecute": "'$commandToExecute'" }'
echo $protectedSettings

az vm extension set -n CustomScriptExtension \
    --publisher Microsoft.Compute --version 1.10 \
    --vm-name vm-devops-1201 --resource-group rg-secure-appsvc-prod \
    --protected-settings $protectedSettings \
    --verbose

az vm extension set -n CustomScriptExtension \ 
    --publisher Microsoft.Compute --version 1.10 \    
    --vm-name vm-devops-1201 --resource-group rg-secure-appsvc-prod \
    --protected-settings '{"fileUris": "['https://raw.githubusercontent.com/Azure/appservice-landing-zone-accelerator/main/scenarios/shared/scripts/win-devops-vm-extensions/post-deployment.ps1']", "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File post-deployment.ps1 -az_cli_commands \"az version\" -install_ssms" }' \
    --verbose