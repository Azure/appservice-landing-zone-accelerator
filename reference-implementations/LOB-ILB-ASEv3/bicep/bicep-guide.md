# App Service Landing Zone Accelerator - Bicep Template Usage

When we developed this Landing Zone Accelerator, we chose Bicep as our first Infrastructure as Code deployment method due to its many advantages. We were excited about trying a new IaC experience and drawn to its declarative nature and ease to onboard compared to ARM templates. 

Bicep is our chosen IaC language and we have built GitHub actions to validate and deploy this Landing Zone Accelerator. 

For more information please see the [Bicep Document](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)

## How to deploy Bicep using Automation
We had prepared a GitHub Action to validate / deploy Bicep you can see the Action file in [here](/.github/workflows/LOB-ILB-ASEv3-Bicep.yml)

Thsi action consist of two main parts
- Validate 
- Build and Deploy

### Validate the Bicep file

```console
az bicep build -f main.bicep
```

During this Validate step we run Bicep build command which check the file(s) and also runs linter. Checks your code syntax and spelling erros etc. Behind the science JSON ARM template would be generated and if it's correctly generated after the validation it would be discarded.

### Build and Deploy the Bicep file 
After the linter step if there is no syntax errors etc, we run another validation and deploy, here are the steps,

- In order to parse our config.yaml file we download the yq library
- Parse the config.yaml file and obtain key - value pairs.
- Login to Azure env with our credentials that we keep in GitHub
- We run Preflight validation, this validation is more complex than linter, it actually communicate with the ARM Engine and do more comphrinsive validation.
- Lastly we deploy the Bicep file to a subscription which requires to deploy more than one Resource Group. 
