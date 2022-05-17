$LOCATION="eastus"
$BICEP_FILE="main.bicep"
$DEPLOYMENT_NAME=('ase-' + (Get-Date -Format "yyyyMMdd-HHmmss"))

# make a copy of parameters json file. localparam.json is not committed to repo
# put the variables you need in localparam.json and then reference it in the $PARAM_FILE
# Copy-Item parameters.json localparam.json

# set this to file with parameter. localparam*.json is not committed to git
$PARAM_FILE="localparam.json"

$RESULTS=((az deployment sub create --name $DEPLOYMENT_NAME --template-file $BICEP_FILE --parameters $PARAM_FILE --location $LOCATION -o json) | ConvertFrom-Json)

$rgAse=$RESULTS.properties.outputs.aseResourceGroupName
$rgShared=$RESULTS.properties.outputs.sharedResourceGroupName
$rgNetworking=$RESULTS.properties.outputs.networkResourceGroupName

Write-Host "Resource groups created: " + $rgAse + ", " + $rgShared + ", " + $rgNetworking

# # az group delete -n $rgAse --yes
# # az group delete -n $rgShared --yes
# # az group delete -n $rgNetworking --yes