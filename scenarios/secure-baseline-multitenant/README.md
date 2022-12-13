# Multitenant App Service Secure Baseline

This reference architecture shows how to run a web-app workload on Azure App Services in a secure configuration. This secure baseline follow [Defence in Depth](https://learn.microsoft.com/en-us/shows/azure-videos/defense-in-depth-security-in-azure) approach to protect AppService workload against cloud vulnerabilities along with additional [Well-Architected Framework](https://learn.microsoft.com/en-us/azure/architecture/framework/) pillars to enable a resilent soltion.

## Architecture
![image](/docs/Images/AppServiceLandingZoneArchitecture-multitenant.png)

Download a Visio file that contains this architecture diagram.

A deployment of App Service-hosted workloads typically requires a separation of duties and lifecycle management in different areas, such as prerequisites, the host network, the cluster infrastructure, the shared services and finally the workload itself. This reference implementation is no different. Also, be aware that our primary purpose is to illustrate the topology and decisions involved in the deployment of a secure App Service infrastructure. We feel a "step-by-step" flow will help you learn the pieces of the solution and will give you insight into the relationship between them. Ultimately, lifecycle/SDLC management of your cluster and its dependencies will depend on your situation (organizational structures, standards, processes and tools), and will be implemented as appropriate for your needs.

## Core architecture components
* The application's users are authenticated by [Azure Active Directory (Azure AD)](https://azure.microsoft.com/services/active-directory/) or [Azure AD B2C](https://azure.microsoft.com/services/active-directory/external-identities/b2c/). The browser performs DNS lookups to resolve addresses to Azure Front Door.
* [Azure Front Door](https://azure.microsoft.com/services/frontdoor/) is a public front-end for all internet requests, acting as a global HTTP reverse proxy and cache in front of several Azure services. Front Door also provides automatic protection from layer 3 and 4 DDoS attacks, and a range of other features including WAF (web application firewall), caching, and custom rules to enhance the security and performance of your application.
* [Azure App Service (Premium)](https://azure.microsoft.com/services/app-service/) hosts the front-end API applications that are called by the app. Deployment slots are used to provide zero-downtime releases.
* App Services use [Virtual Network (VNet) Integration](https://learn.microsoft.com/en-us/azure/app-service/overview-vnet-integration#regional-virtual-network-integration) to connect to backend Azure services over a private VNet.
* [Azure Cache for Redis](https://azure.microsoft.com/services/cache/) provides a high-performance distributed cache for output, session, and general-purpose caching.
* [Azure SQL DB](https://azure.microsoft.com/en-us/products/azure-sql/database/) provides a fully managed relational database service for back-end application services.
[Private Endpoints](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview) allow connections to Azure services from private VNets, and allow the public endpoints on these services to be disabled.
* [Azure private DNS](https://learn.microsoft.com/en-us/azure/dns/private-dns-overview) automatically configures and updates the DNS records required by private endpoint services.
* [Azure Key Vault](https://azure.microsoft.com/services/key-vault/) securely stores secrets and certificates to be accessed by Azure services.
* [Azure Monitor](https://azure.microsoft.com/services/monitor/) and [Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview) collect service logs and application performance metrics for observability.

## Networking
Private endpoints are used throughout this architecture to improve security. While private endpoints don't directly improve, or reduce, the availability of this solution, they allow important security principles to be applied. For more information about security design principles, see [Azure well architected framework - Security pillar](https://learn.microsoft.com/en-us/azure/architecture/framework/security/security-principles).

Network segmentation boundaries are established along public and private lines. Azure Front Door and Azure App Service are designed to operate on the public internet. These services have their public endpoints enabled. However, App Service has access restrictions in place to ensure that only traffic allowed by Front Door WAF (Web Application Firewall) is allowed to ingress into the App Service.

Azure services that don't require access from the public internet have private endpoints enabled and public endpoints disabled. The Azure data services SQL DB, SQL DB and Azure Cache for Redis all have public endpoints disabled. Each private endpoint is deployed into one subnet that is dedicate to integrated private link services. Azure service firewalls are used to only allow traffic from other authorized Azure services. Private DNS zones are linked to each private endpoint, via private DNS zone groups and virtual network links, to ensure that private link DNS records are automatically created and updated.

For network and subnet topology details, see the [Azure sample template](https://github.com/Azure-Samples/highly-available-zone-redundant-webapp) for this architecture.

## Alternatives
* Either Azure AD or Azure AD B2C can be used as an identity provider in this scenario. Azure AD is designed for internal applications and business-to-business (B2B) scenarios, while Azure AD B2C is designed for business-to-consumer (B2C) scenarios.
* You can choose to bring your own own DNS provider or use Azure-managed DNS, which is recommended.
* Azure Application Gateway can be used solely instead of Azure Front Door when most users are located close to the Azure region that hosts your workload, and when content caching isn't required. Azure DDoS Network Protection is recommended for protecting internet-facing Application Gateway services.
* A premium Azure API Manager instance deployed with zone-redundancy enabled is a good alternative for hosting frontend APIs, backend APIs, or both. For more information about zone-redundancy in API Manager, see Availability zone support.

## Scenario details


## Recommendations
* App Service 
    - Access restrictions on Azure App Service should be configured to only allow Front Door traffic. Access restrictions ensure that requests aren't able to bypass the Azure Front Door WAF.
    - All service-to-service communication in Azure is TLS (transport layer security) encrypted by default. Azure Front Door, Azure App Services, and Azure Static Web Apps should be configured to accept HTTPS traffic only, and the minimum TLS version set.
    - Managed identities are used for authenticating Azure service-to-service communication, where available. For more information about managed identities, see What are managed identities for Azure resources?.

## Recommendations
Private endpoints are mostly available on Premium Azure service SKUs. Private endpoints incur hourly and bandwidth (data) charges. For more information, see Private Link pricing.

# Storage Account
* Harden your Azure Storage access with 
    - secure protocols (https://learn.microsoft.com/en-us/azure/storage/common/storage-require-secure-transfer)
    - Configure your Azure Storage firewall to deny public internet traffic (https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security?tabs=azure-portal)
# SQL Database
* Define your encryption policy
* internal FW

# Cache for Redis
* Set the publicNetworkAccess flag to Disabled to disable the public endpoint.


## Deploy this scenario


## Considerations for Azure Government cloud

Azure Front Door Premium is not available in Azure Government cloud.  The reference implementation will deploy an Azure Application Gateway instead.




# Potential use cases



## Next

Pick one of the IaC options below and follow the instructions to deploy the App Service reference implementation.

:arrow_forward: [Terraform](./Terraform)

:arrow_forward: [Bicep](./Bicep)
