$RESOURCE_GROUP = "tesatase"
$LOCATION = "westeurope"
$BICEP_FILE="main.bicep"

# delete a deployment
az deployment sub  delete  --name testasedeployment

# deploy the bicep file directly

# make a copy of parameters json file. localparam.json is not committed to repo
# put the variables you need in localparam.json
copy parameters.json localparam.json


az deployment sub  create --name testasedeployment   --template-file $BICEP_FILE   --parameters localparam.json --location $LOCATION -o json
