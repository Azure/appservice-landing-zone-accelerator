# Multitenant App Service Secure Baseline

A deployment of App Service-hosted workloads typically requires a separation of duties and lifecycle management in different areas, such as prerequisites, the host network, the cluster infrastructure, the shared services and finally the workload itself. This reference implementation is no different. Also, be aware that our primary purpose is to illustrate the topology and decisions involved in the deployment of a secure App Service infrastructure. We feel a "step-by-step" flow will help you learn the pieces of the solution and will give you insight into the relationship between them. Ultimately, lifecycle/SDLC management of your cluster and its dependencies will depend on your situation (organizational structures, standards, processes and tools), and will be implemented as appropriate for your needs.

## Core architecture components

* App Service Premium
* Azure Front Door Premium
* Azure Key Vault
* Azure App Configuration
* Azure Redis Cache
* Azure Sql Database

## Considerations for Azure Government cloud

Azure Front Door Premium is not available in Azure Government cloud.  The reference implementation will deploy an Azure Application Gateway instead.

## Next

Pick one of the IaC options below and follow the instructions to deploy the App Service reference implementation.

:arrow_forward: [Terraform](./Terraform)

:arrow_forward: [Bicep](./Bicep)
