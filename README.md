# App Service Landing Zone Accelerator

This repository encompasses both enterprise architecture guidelines and a reference implementation for deploying Azure App Service solutions in multi-tenant and App Service Environment scenarios. It includes best practices, considerations and deployable artifacts for implementing a common reference architecture.

[aka.ms/EnterpriseScale-AppService](https://aka.ms/EnterpriseScale-AppService)

![image](/docs/Images/home-page.gif)

## Enterprise-Scale Architecture

The enterprise architecture is broken down into six different design areas, where you can find the links to each at:
| Design Area|Considerations|Recommendations|
|--------------|--------------|--------------|
| Identity and Access Management|[Design Considerations](/docs/Design-Areas/identity-access-mgmt.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/identity-access-mgmt.md#design-recommendations)|
| Network Topology and Connectivity|[Design Considerations](/docs/Design-Areas/networking.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/networking.md#design-recommendations)|
| Management and Monitoring|[Design Considerations](/docs/Design-Areas/mgmt-monitoring.md#design-consideration)|[Design Recommendations](/docs/Design-Areas/mgmt-monitoring.md#design-recommendation)|
| Business Continuity and Disaster Recovery|[Design Considerations](/docs/Design-Areas/BCDR.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/BCDR.md#design-recommendations)|
| Security, Governance, and Compliance|[Design Considerations](/docs/Design-Areas/security-governance-compliance.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/security-governance-compliance.md#design-recommendations)|
| Application Automation and DevOps|[Design Considerations](/docs/Design-Areas/automation-devops.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/automation-devops.md#design-recommendations)|

## Enterprise-Scale Reference Implementation

In this repo you will find reference implementations with supporting Infrastructure as Code templates. More reference implementations will be added as they become available. [User guide](/docs/README.md) goes into details on how to deploy each reference implementations to your subscription. 

## Next Steps to implement the Azure App Service Landing Zone Accelerator
> Reference implementations

Pick one of the scenarios below to get started on a reference implementation.

:arrow_forward: [Scenario 1: Multitenant App Service Secure Baseline](scenarios/secure-baseline-multitenant/README.md)

:arrow_forward: [Scenario 2: Line of Business application using internal App Service Environment v3](scenarios/secure-baseline-ase//README.md)

---

## Got a feedback

Please leverage issues if you have any feedback or request on how we can improve on this repository.

---
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft's privacy statement. Our privacy statement is located at https://go.microsoft.com/fwlink/?LinkId=521839. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.

### Telemetry Configuration

Telemetry collection is on by default.

To opt-out, set the variable enableTelemetry to `false` in Bicep/ARM file and disable_terraform_partner_id to `false` on Terraform files.

---

## Contributing

See more at [Contributing](CONTRIBUTING.md)

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
