# App Service Landing Zone Accelerator

This is a repository ([aka.ms/EnterpriseScale-AppService](https://aka.ms/EnterpriseScale-AppService)) that contains both enterprise architecture (proven recommendations and considerations across both multi-tenant and App Service Environment use cases) and reference implementation (deployable artifacts for a common implementation). 

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
In this repo you will find reference implementations with supporting Infrastructure as Code templates. More reference implementations will be added as they become available. [User guide](/docs/README.md) goes into details on how to deploy each reference implementations to your subscription. 

---

### [Reference Implementation 1](/reference-implementations/LOB-ILB-ASEv3/bicep): Line of Business application using internal App Service Environment v3
Architectural Diagram:

![image](https://user-images.githubusercontent.com/37597107/133897423-4de9c66f-d033-4839-81b2-4e9d8a12253d.png)

Deployed Resources:

![image](https://user-images.githubusercontent.com/37597107/133897451-9a6d0a07-873c-4f87-81de-29b15d576e4b.png)

Deployment Details:
| Deployment Methodology | GitHub Actions
|--------------|--------------|
|[Bicep](/reference-implementations/LOB-ILB-ASEv3/bicep/README.md)|[LOB-ILB-ASEv3-Bicep.yml](/.github/workflows/LOB-ILB-ASEv3-Bicep.yml)
|[ARM](/reference-implementations/LOB-ILB-ASEv3/azure-resource-manager/README.md)| Not provided* |
|[Terraform](/reference-implementations/LOB-ILB-ASEv3/terraform/README.md)|Coming Soon|

Cost estimation:

The current default will cost approx. $40-$50 per day depending on the selected region (without any workload). It is deploying an ASE V3 that is zone-redundant and one Isolated V2 SKU Windows App Service Plan scaled to 3 instances (default with zone redundancy). For more accurate prices please check [pricing models for ASE V3](https://docs.microsoft.com/en-us/azure/app-service/environment/overview#pricing). 

---

## Other Considerations
1. Please leverage issues if you have any feedback or request on how we can improve on this repository.

---
## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
