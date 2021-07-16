$RESOURCE_GROUP = "tesatase"
$LOCATION = "westeurope"
$BICEP_FILE="main.bicep"

# delete a deployment
az deployment sub  delete  --name testasedeployment

# deploy the bicep file directly

az deployment sub  create --name testasedeployment   --template-file $BICEP_FILE   --parameters parameters.json --location $LOCATION -o json
