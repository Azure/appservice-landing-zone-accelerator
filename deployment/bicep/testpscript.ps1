$LOCATION = "westeurope"
$BICEP_FILE="main.bicep"

# set this to file with parameter. localparam*.json is not committed to git
$PARAM_FILE="localparamgh.json"



# make a copy of parameters json file. localparam.json is not committed to repo
# put the variables you need in localparam.json
copy parameters.json localparam.json


az deployment sub  create --name testasedeployment7   --template-file $BICEP_FILE   --parameters $PARAM_FILE --location $LOCATION -o json
