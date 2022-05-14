$LOCATION = "westeurope"
$BICEP_FILE="main.bicep"
$DEPLOYMENT_NAME=('ase-' + (Get-Date -Format "yyyyMMdd-HHmmss"))

# make a copy of parameters json file. localparam.json is not committed to repo
# put the variables you need in localparam.json and then reference it in the $PARAM_FILE
# Copy-Item parameters.json localparam.json

# set this to file with parameter. localparam*.json is not committed to git
$PARAM_FILE="localparam.json"

az deployment sub create --name $DEPLOYMENT_NAME --template-file $BICEP_FILE --parameters $PARAM_FILE --location $LOCATION -o json