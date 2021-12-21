# App Service Landing Zone Accelerator

This is a repository ([aka.ms/EnterpriseScale-AppService](https://aka.ms/EnterpriseScale-AppService)) that contains both enteprrise architecture (proven recommendations and considerations across both multi-tenant and App Service Environment use cases) and reference implementaion (deployable artifacts for a common implementations). 

## Enterprise-Scale Architecture
The enterprise architecture is broken down into six different design areas, where you can find the links to each at:
| Design Area      |
|--------------|
| [Identity and Access Management](https://github.com/cykreng/Enterprise-Scale-AppService/blob/main/docs/Design-Areas/identity-access-mgmt.md) |
| [Network Topology and Connectivity ](https://github.com/cykreng/Enterprise-Scale-AppService/blob/main/docs/Design-Areas/networking.md)    |
| [Management and Monitoring](https://github.com/cykreng/Enterprise-Scale-AppService/blob/main/docs/Design-Areas/mgmt-monitoring.md)|
|[Business Continuity and Disaster Recovery](https://github.com/cykreng/Enterprise-Scale-AppService/blob/main/docs/Design-Areas/BCDR.md)|
|[Security, Governance, and Compliance](https://github.com/cykreng/Enterprise-Scale-AppService/blob/main/docs/Design-Areas/security-governance-compliance.md)|
|[Application Automation and DevOps](https://github.com/cykreng/Enterprise-Scale-AppService/blob/main/docs/Design-Areas/automation-devops.md)|

## Enterprise-Scale Reference Implementation
In this repo you will also find reference implementations with supporting Infrastructe as Code templates. More reference implementations will be added as they become available. 

---

### Reference Implementation 1: Line of Business application using internal App Service Environment v3
Architectural Diagram:
![image](https://user-images.githubusercontent.com/37597107/133897423-4de9c66f-d033-4839-81b2-4e9d8a12253d.png)

Deployed Resources:

![image](https://user-images.githubusercontent.com/37597107/133897451-9a6d0a07-873c-4f87-81de-29b15d576e4b.png)

Deployment Details:
| Deployment Methodology| GitHub Action YAML|
|--------------|--------------|
|[Bicep](https://github.com/cykreng/Enterprise-Scale-AppService/tree/main/deployment/bicep) |[ase-cs-deploy.yml](https://github.com/cykreng/Enterprise-Scale-AppService/blob/main/.github/workflows/ase-cs-deploy.yml)
| ARM (Coming soon) ||
| Terraform (Coming soon)||
---

## Other Considerations
1. Here are the [pricing models for ASE V3](https://docs.microsoft.com/en-us/azure/app-service/environment/overview#pricing). The current default is to deploy an ASE V3 that is zone-redundant and one Isolated V2 SKU Windows App Service Plan scaled to 3 instances (default with zone redundancy)
2. Please leverage issues if you have any feedback or request on how we can improve on this repository

