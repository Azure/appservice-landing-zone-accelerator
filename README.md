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
| Deployment Methodology| GitHub Action YAML|
|--------------|--------------|
|[Bicep](/reference-implementations/LOB-ILB-ASEv3/bicep)|[LOB-ILB-ASEv3-Bicep.yml](/.github/workflows/LOB-ILB-ASEv3-Bicep.yml)
|[ARM](/reference-implementations/LOB-ILB-ASEv3/azure-resource-manager/ase-arm.json) (In specific branch) |N/A|This doc
| Terraform (Coming soon)||

Cost estimation:

The current default will cost approx. $40-$50 per day depending on the selected region (without any workload). It is deploying an ASE V3 that is zone-redundant and one Isolated V2 SKU Windows App Service Plan scaled to 3 instances (default with zone redundancy). For more accurate prices please check [pricing models for ASE V3](https://docs.microsoft.com/en-us/azure/app-service/environment/overview#pricing). 

---

## Generating the ARM Template

### Process

When we developed this Landing Zone Accelerator, we chose Bicep as our first Infrastructure as Code deployment method due to its many advantages. We were excited about trying a new IaC experience and drawn to its declarative nature and ease to onboard compared to ARM templates. Another benefit that we recognized was the capability to generate ARM templates from a Bicep template, which we leverage as part of our GitHub workflow. 

During our deployment, we added several Bicep validation / preflight checks as seen in our [Action yaml file](/.github/workflows/es-ase.yml). If those validations pass without errors, we continue to deploy the Bicep template. If Bicep deploys without any error, we begin to generate the ARM template as a next [Job](https://docs.github.com/en/actions/using-jobs/using-jobs-in-a-workflow) in GitHub Action using the command below. We have opted to not include additional validation steps solely on the ARM template given the reasons specified below. 

```yaml
az bicep build --file main.bicep --outfile ../azure-resource-manager/ase-arm.json
```

### Storing the ARM Template

After the ARM Template is generated, we create a branch from the main branch and uses the 'run_number' of GitHub Action to push the ARM template to the newly created branch.

Again, you can find the details in [Action yaml file](/.github/workflows/es-ase.yml)

### Generated ARM Template Validation
---
There are several ways to **Validate** an ARM Template;

- Syntax: Code

- Behavior: What is the code doing that you may want to be aware of? Are you handling secure parameters (e.g. secrets) correctly? Is the use of location for resources reasonable? Do you have practices that may cause problems across environments (subs, clouds, etc.)?

- Result: What does the code do (deploy) or not that you may want to be aware of? (no NSGs or NSGs too permissive, password vs key authentication)

- Intent: Does the code do what it is intended to do?

- Success: Does the code successfully deploy?

**Syntax**: For syntax check ```bicep build``` completes that validation.

**Behavior**: Bicep completes most of behavior checks, while [arm-ttk](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/test-toolkit) has some additional capabilities that will eventually be incorporated into Bicep or other tools. 

**Result**: This can be covered using [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/overview). 

**Intent**: We can run what-if scenarios on the ARM Template. This, however, requires human interaction and thus cannot be automated. 

**Success**: Since before ARM Template, Bicep template finished successfully (otherwise ARM Template generation step would not start) so we are sure that ARM Template will work, so no need to add any validation on that. This doesn't guarantee a successful deployment as there may be other factors such as region availability, user permission, policy conflict that could lead to a failed deployment even if the ARM template is completely valid. 

As a result, since the ARM Template is  generated from the Bicep template, additional steps to **validate the ARM Template** are negligible.

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
