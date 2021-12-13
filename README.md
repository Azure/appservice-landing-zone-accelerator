# Enterprise-Scale-AppService

This is a repository ([aka.ms/EnterpriseScale-AppService](https://aka.ms/EnterpriseScale-AppService)) that contains both enteprrise architecture (proven recommendations and considerations across both multi-tenant and App Service Enviroonment use cases) and reference implementaion (deployable artifacts for a common implementations). 

The enterprise architecture is broken down into six different design areas, where you can find the links to each at:
| Design Area      |
|--------------|
| [Identity and Access Management](https://github.com/cykreng/Enterprise-Scale-AppService/blob/main/docs/Design-Areas/identity-access-mgmt.md) |
| [Network Topology and Connectivity ](https://github.com/cykreng/Enterprise-Scale-AppService/blob/main/docs/Design-Areas/networking.md)    |
| [Management and Monitoring](https://github.com/cykreng/Enterprise-Scale-AppService/blob/main/docs/Design-Areas/mgmt-monitoring.md)|
|[Business Continuity and Disaster Recovery](https://github.com/cykreng/Enterprise-Scale-AppService/blob/main/docs/Design-Areas/BCDR.md)|
|[Security, Governance, and Compliance](https://github.com/cykreng/Enterprise-Scale-AppService/blob/main/docs/Design-Areas/security-governance-compliance.md)|
|[Application Automation and DevOps](https://github.com/cykreng/Enterprise-Scale-AppService/blob/main/docs/Design-Areas/automation-devops.md)|

In this repo, you will also find reference implementations with supporting Infrastructe as Code templates. More reference implementations will be added as they become available. 

1. Use case: Line of Business application using internal App Service Environment v3
    Architectural Diagram:
    ![image](https://user-images.githubusercontent.com/37597107/133897423-4de9c66f-d033-4839-81b2-4e9d8a12253d.png)

    Deployed Resources:

    ![image](https://user-images.githubusercontent.com/37597107/133897451-9a6d0a07-873c-4f87-81de-29b15d576e4b.png)

Important Points:

1. Here are the [pricing models for ASE V3](https://docs.microsoft.com/en-us/azure/app-service/environment/overview#pricing). The current default is to deploy an ASE V3 that is zone-redundant and one Isolated V2 SKU Windows App Service Plan scaled to 3 instances (default with zone redundancy)
2. Please leverage issues if you have any feedback or request on how we can improve on this repository. 

