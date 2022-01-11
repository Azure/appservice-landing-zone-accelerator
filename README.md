# App Service Landing Zone Accelerator

This is a repository ([aka.ms/EnterpriseScale-AppService](https://aka.ms/EnterpriseScale-AppService)) that contains both enteprrise architecture (proven recommendations and considerations across both multi-tenant and App Service Environment use cases) and reference implementaion (deployable artifacts for a common implementation). 

## Enterprise-Scale Architecture
The enterprise architecture is broken down into six different design areas, where you can find the links to each at:
| Design Area|Considerations|Recommendations|
|:--------------:|:--------------:|:--------------:|
| Identity and Access Management|[Design Considerations](/docs/Design-Areas/identity-access-mgmt.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/identity-access-mgmt.md#design-recommendations)|
| Network Topology and Connectivity|[Design Considerations](/docs/Design-Areas/networking.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/networking.md#design-recommendations)|
| Management and Monitoring|[Design Considerations](/docs/Design-Areas/mgmt-monitoring.md#design-consideration)|[Design Recommendations](/docs/Design-Areas/mgmt-monitoring.md#design-recommendation)|
| Business Continuity and Disaster Recovery|[Design Considerations](/docs/Design-Areas/BCDR.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/BCDR.md#design-recommendations)|
| Security, Governance, and Compliance|[Design Considerations](/docs/Design-Areas/security-governance-compliance.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/security-governance-compliance.md#design-recommendations)|
| Application Automation and DevOps|[Design Considerations](/docs/Design-Areas/automation-devops.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/automation-devops.md#design-recommendations)|

## Enterprise-Scale Reference Implementation
In this repo you will find reference implementations with supporting Infrastructer as Code templates. More reference implementations will be added as they become available. [User guide](/docs/README.md) goes into details on how to deploy each reference implementations to your subscription. 

---

### [Reference Implementation 1](/reference-implementations/LOB-ILB-ASEv3/bicep): Line of Business application using internal App Service Environment v3
Architectural Diagram:

![image](https://user-images.githubusercontent.com/37597107/133897423-4de9c66f-d033-4839-81b2-4e9d8a12253d.png)

Deployed Resources:

![image](https://user-images.githubusercontent.com/37597107/133897451-9a6d0a07-873c-4f87-81de-29b15d576e4b.png)

Deployment Details:
| Deployment Methodology| GitHub Action YAML|
|--------------|--------------|
|[Bicep](/reference-implementations/LOB-ILB-ASEv3/bicep)|[LOB-ILB-ASEv3-Bicep.yml](/.github/workflows/LOB-ILB-ASEv3-Bicep.yml)
| ARM (Coming soon) ||
| Terraform (Coming soon)||
---

## Other Considerations
1. Here are the [pricing models for ASE V3](https://docs.microsoft.com/en-us/azure/app-service/environment/overview#pricing). The current default is to deploy an ASE V3 that is zone-redundant and one Isolated V2 SKU Windows App Service Plan scaled to 3 instances (default with zone redundancy)
2. Please leverage issues if you have any feedback or request on how we can improve on this repository

