# /bin/bash

az vm extension set -n CustomScriptExtension \
    --publisher Microsoft.Compute --version 1.10 \
	--vm-name vm-lza-app-beta-win-jumpbox \
	--resource-group rg-spoke-lza-app-beta-dev-francecentral \
	--settings '{"fileUris": ["https://raw.githubusercontent.com/Azure/appservice-landing-zone-accelerator/feature/external-outputs/scenarios/shared/scripts/win-devops-vm-extensions/post-deployment.ps1"]}' \
	--protected-settings  '{"commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File post-deployment.ps1 -install_cli" }' \
	--verbose