# Multitenant App Service Secure Baseline ARM Template Implementation

## Steps of Implementation for App Service Construction Set

A deployment of App Service-hosted workloads typically experiences a separation of duties and lifecycle management in the area of prerequisites, the host network, the App Service plan, and finally the workload itself. This reference implementation is similar. Also, be aware our primary purpose is to illustrate the topology and decisions of a baseline cluster. We feel a "step-by-step" flow will help you learn the pieces of the solution and give you insight into the relationship between them. Ultimately, lifecycle/SDLC management of your cluster and its dependencies will depend on your situation (team roles, organizational standards, tooling, etc), and must be implemented as appropriate for your needs.

## Accounting for Separation of Duties

While the code here is located in one folder in a single repo, the steps are designed to mimic how an organization may break up the deployment of various Azure components across teams, into different code repos or have them run by different pipelines with specific credentials. 

## Keeping It As Simple As Possible

The code here is purposely written to avoid loops, complex variables and logic. In most cases, it is resource blocks, small modules and limited variables, with the goal of making it easier to determine what is being deployed and how they are connected. Resources are broken into separate files for future modularization or adjustments as needed by your organization.

## Getting Started

This section is organized using folders that match the steps outlined below. Make any necessary adjustments to the variables and settings within that folder to match the needs of your deployment.

### Prerequisites

Clone this repo, install Azure CLI .

[Install Azure CLI ](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)

### Create parameters.json file




### Deploy the App Service Landing Zone ARM Template

```bash
TBD!

```
### Approve the App Service private endpoint connection from Front Door in the Azure Portal

This is a manual step that is required to complete the private endpoint connection.

### Retrieve the Azure Front Door frontend endpoint URL and test the App Service

```bash
az network front-door frontend-endpoint show --front-door-name <front-door-name> --name <front-door-frontend-endpoint-name> --resource-group <front-door-resource-group>```  
```

## TBD: Deploying App Service into Existing Infrastructure

The steps above assume that you will be creating the Hub and Spoke (Landing Zone) Network and supporting components using the code provided, where each step refers to state file information from the previous steps.

To deploy App Service into an existing network, use the [App Service for Existing Cluster](./07-App Service-cluster-existing-infra) folder.  Update the "existing-infra.variables.tf" file to reference the names and resource IDs of the pre-existing infrastructure.