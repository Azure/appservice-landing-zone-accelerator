> The H1 title is the same as the title metadata. Don't enter it here, but as the **name** value in the corresponding YAML file.

_Brief introduction goes here._ [**Deploy this solution**.](#deploy-the-solution)

![alt text.](./media/folder_name/architecture-diagram.png)

_Download a [Visio file](https://arch-center.azureedge.net/architecture.vsdx) that contains this architecture diagram. This file must be uploaded to `https://arch-center.azureedge.net/`_

## Architecture

Include visio diagram

### Components

The solution uses the following Azure services:

- **App Service Environment v3**. [App Service Environment v3 (ASEv3)](https://docs.microsoft.com/en-us/azure/app-service/environment/overview) is a single tenant  service for customers that require high scale, network isolation and security, or high memory utilization. Apps are hosted in [App Service plans](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans) created in ASEv3 with options of using different tiers within Isolated v2 Service Plan. Improvements have been made including but not limited to netowrk dependency, scale time, and the removal of stamp fee compared to earlier versions of ASE. This reference architecutre uses an internal App Service Environment v3. 
  
 - **Private DNS zone**. [Azure Private DNS](https://docs.microsoft.com/en-us/azure/dns/private-dns-privatednszone) allows users to manage and resolve domain names within a virtual netowrk without needing to implement a custom DNS solution. A Private Azure DNS zone can be lined to one or more virtual netowrks through [virtual netowrk links](https://docs.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links). Due to the internal nature of the ASEv3 this reference architecture uses, a private DNS zone is required to resolve the domain names of applications hosted on the App Service Environment.

- **Application Insights**. [Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview) is a feature of Azure Monitor that helps Developers detect anomalies, diagnose issues, and understand usage patterns with extensible application performance management and monitoring for live web apps. A variety of platforms including .NET, Node.js, Java, and Python are supported for apps that are hosted on-prem, hybrid, or other public clouds. Application Insights is included as part of this reference architecture to monitor behaviors of the deployed application.

- **Log Analytics**. [Log Analytics](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview) is a feature of Azure Monitor that allows users to edit and run log quieries with data in Azure Monitor Logs in the Azure portal. Developers can run simple queries for a set of records or use Log Analytics to perform advanced analysis and visualiza results. Log Analytics is configured as part of this reference architecture to aggregate all the monitoring logs for additional analysis.

- **Virtual Machine**. [Azure Virtual Machine](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/overview) is an on-demand, scalable computing resource that can be used to host a number of different workloads. In this reference architecutre, the virtual machine is used as a management jumbox as well as a DevOps agent. 

- **Key Vault**. [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/general/basic-concepts) is a cloud service to securely store and access secrets ranging from API keys and passwords to certificates and cryptographic keys. There are no secrets stored in the Key Vault as part of the infrastructure deployment of this reference architecture, but the Key Vault is deployed to facilitate secret management for future code deployments. 

- **Azure Bastion**. [Azure Bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview) is a Platform-as-a-Service service provisioned within the developer's virtual netowrk which provides secure RDP/SSH connectivity to the developer's virtual machines over TLS from the Azure portal. With Azure Bastion, virtual machines no longer require a public IP address to connect via RDP/SSH. This reference architecutre uses Azure Bastion to access the DevOps Agent or the Management Jumpbox. 



## Recommendations

The following recommendations apply for most scenarios. Follow these recommendations unless you have a specific requirement that overrides them.

_Include considerations for deploying or configuring the elements of this architecture._

## Scalability considerations

_Identify and address scalability concerns relevant to the architecture in this scenario._

## Availability considerations
AZ within the region

_Identify and address availability concerns relevant to the architecture in this scenario._

## Manageability considerations

_Identify and address manageability concerns relevant to the architecture in this scenario._

## Security considerations

_Identify and address security concerns relevant to the architecture in this scenario._

## Cost Considerations
[Reserved instance](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans)

## Deploy this scenario

A deployment for the reference architecture that implements these recommendations and considerations is available on [GitHub](https://github.com/Azure/appservice-landing-zone-accelerator/tree/main/reference-implementations/LOB-ILB-ASEv3).



## Next steps

* [Security in Azure App Service](/azure/app-service/overview-security)
* [Networking for App Service](/azure/app-service/networking-features)

## Related resources


* [High availability enterprise deployment using App Services Environment](docs/reference-architectures/enterprise-integration/ase-high-availability-deployment.yml)
* [Enterprise deployment using App Services Environment](docs/reference-architectures/enterprise-integration/ase-standard-deployment.yml)
