# Multitenant App Service Secure Baseline

This reference architecture shows how to run a web-app workload on Azure App Services in a secure configuration. This secure baseline follow [Defense in Depth](https://learn.microsoft.com/en-us/shows/azure-videos/defense-in-depth-security-in-azure) approach to protect AppService workload against cloud vulnerabilities along with additional [Well-Architected Framework](https://learn.microsoft.com/en-us/azure/architecture/framework/) pillars to enable a resilient solution.

## Quick deployment to Azure
You can deploy the current LZA directly in your azure subscription by hitting the button below or using Azure Dev CLI. 

### Deploy to Azure via Portal

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fappservice-landing-zone-accelerator%2Fmain%2Fscenarios%2Fsecure-baseline-multitenant%2Fazure-resource-manager%2Fmain.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fappservice-landing-zone-accelerator%2Fmain%2Fscenarios%2Fsecure-baseline-multitenant%2Fazure-resource-manager%2Fmain-portal-ux.json)

### Using Codespaces via Azure Dev CLI 

- Visit [github.com/Azure/appservice-landing-zone-accelerator](https://github.com/Azure/appservice-landing-zone-accelerator)
- Click on the `Green Code` button.
- Navigate to the `CodeSpaces` tab and create a new code space.
- Open the terminal by pressing <code>Ctrl + `</code>.
- Navigate to the scenario folder using the command `cd /workspaces/appservice-landing-zone-accelerator/scenarios/secure-baseline-multitenant`.
- Login to Azure using the command `azd auth login`.
- Use the command `azd up` to deploy, provide environment name and subscription to deploy to.
- Finally, use the command `azd down` to clean up resources deployed.

# Architecture
![image](/docs/Images/Multitenant/AppServiceLandingZoneArchitecture-multitenant.png)


## Core architecture components
* The application's users are authenticated by [Azure Active Directory (Azure AD)](https://azure.microsoft.com/services/active-directory/) or [Azure AD B2C](https://azure.microsoft.com/services/active-directory/external-identities/b2c/). The browser performs DNS lookups to resolve addresses to Azure Front Door.
* [Virtual Network](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-group-how-it-works) enables Azure resources to securely communicate with each other, the internet, and on-premises networks by creating boundaries, isolation and segmentation of your workloads in the cloud, much like a physical network.
* [Network Security Group](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview?toc=%2Fazure%2Fnetworking%2Ffundamentals%2Ftoc.json) is a set of security policies that Allow or Deny Inbound/Outbound traffic (Protocols/Ports).
* [Azure Front Door](https://azure.microsoft.com/services/frontdoor/) is a public front-end for all internet requests, acting as a global HTTP reverse proxy and cache in front of several Azure services. Front Door also provides automatic protection from layer 3 and 4 DDoS attacks, and a range of other features including WAF (web application firewall), caching, and custom rules to enhance the security and performance of your application.
* [Azure App Service (Premium)](https://azure.microsoft.com/services/app-service/) hosts the front-end API applications that are called by the app. Deployment slots are used to provide zero-downtime releases.
* App Services use [Virtual Network (VNet) Integration](https://learn.microsoft.com/en-us/azure/app-service/overview-vnet-integration#regional-virtual-network-integration) to connect to backend Azure services over a private VNet.
* [Azure Cache for Redis](https://azure.microsoft.com/services/cache/) provides a high-performance distributed cache for output, session, and general-purpose caching.
* [Azure SQL DB](https://azure.microsoft.com/en-us/products/azure-sql/database/) provides a fully managed relational database service for back-end application services.
* [Azure OpenAI](https://learn.microsoft.com/en-us/azure/ai-services/openai/overview) provides REST API access to OpenAI's powerful language models including the GPT-4, GPT-3.5-Turbo, and Embeddings model series.
* [Private Endpoints](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview) allow connections to Azure services from private VNets, and allow the public endpoints on these services to be disabled.
* [Azure private DNS](https://learn.microsoft.com/en-us/azure/dns/private-dns-overview) automatically configures and updates the DNS records required by private endpoint services.
* [Azure Key Vault](https://azure.microsoft.com/services/key-vault/) securely stores secrets and certificates to be accessed by Azure services.
* [Azure Monitor](https://azure.microsoft.com/services/monitor/) and [Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview) collect service logs and application performance metrics for observability.

## Networking

Network design topology is based on [Hub and Spoke](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/hub-spoke-network-topology) that allows to govern, secure and route traffic in a granular mode.

Private endpoints are used throughout this architecture to improve security. While private endpoints don't directly improve, or reduce, the availability of this solution, they allow important security principles to be applied. For more information about security design principles, see [Azure well architected framework - Security pillar](https://learn.microsoft.com/en-us/azure/architecture/framework/security/security-principles).

Network segmentation boundaries are established along public and private lines. Azure Front Door and Azure App Service are designed to operate on the public internet. These services have their public endpoints enabled. However, App Service has access restrictions in place to ensure that only traffic allowed by Front Door WAF (Web Application Firewall) is allowed to ingress into the App Service.

Azure services that don't require access from the public internet have private endpoints enabled and public endpoints disabled. The Azure data services SQL DB, SQL DB and Azure Cache for Redis all have public endpoints disabled. Each private endpoint is deployed into one subnet that is dedicate to integrated private link services. Azure service firewalls are used to only allow traffic from other authorized Azure services. Private DNS zones are linked to each private endpoint, via private DNS zone groups and virtual network links, to ensure that private link DNS records are automatically created and updated.

For network and subnet topology details, see the [Azure sample template](https://github.com/Azure-Samples/highly-available-zone-redundant-webapp) for this architecture.

## Alternatives
* Either Azure AD or Azure AD B2C can be used as an identity provider in this scenario. Azure AD is designed for internal applications and business-to-business (B2B) scenarios, while Azure AD B2C is designed for business-to-consumer (B2C) scenarios.
* You can choose to bring your own DNS provider or use Azure-managed DNS, which is recommended.
* Azure Application Gateway can be used solely instead of Azure Front Door when most users are located close to the Azure region that hosts your workload, and when content caching isn't required. Azure DDoS Network Protection is recommended for protecting internet-facing Application Gateway services.

## Scenario details
The scenario describes a secure baseline that allows you to have a protect environment and a good starting point for designing your solution.
Defense in depth is a security strategy that involves implementing multiple layers of defense at different points within a network or system. The idea is that if one layer of defense is breached, the next layer will be able to prevent an attacker from gaining access to sensitive information or critical systems. 
This approach is a key point that drives the architecture decisions ->
* Use isolated network layers for the different components.
* Use protected AD based access via Managed Identity (where possible).
* Use private endpoints for Azure services.
* Use Network Security Groups to control inbound and outbound traffic in the subnet level.
* Enable Standard DDoS Protection for the SPOKE VNET.

## Potential use cases
* Public website hosting
* Intranet portal
* Mobile app hosting
* E-commerce
* Media streaming
* Machine learning workloads

# Recommendations
* Private endpoints are mostly available on Premium Azure service SKUs. Private endpoints incur hourly and bandwidth (data) charges. For more information, see [Private Link pricing](https://azure.microsoft.com/en-us/pricing/details/private-link/).
* Govern your access and follow [Role Based Access Control](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview) to have a fine-grained access management to Azure resources.
* Review your data classification and determine the protection level you have to enforce in terms of Encryption, Protection, Access and Detection.

## Front Door
Azure Front Door is a global service, always available across all Azure geographies and resilient to zone-wide outages and region-wide outages.

* Use [Azure managed certificates](https://learn.microsoft.com/en-us/azure/frontdoor/standard-premium/how-to-configure-https-custom-domain#azure-managed-certificates) on all front ends to prevent certificate mis-configuration and expiration issues.
* Enable [caching](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-caching?pivots=front-door-standard-premium) on routes where appropriate to improve availability. Front Door's cache distributes your content to the Azure PoP (point of presence) edge nodes. In addition to improving your performance, caching reduces the load on your origin servers.
* Deploy Azure Front Door Premium and configure a [WAF policy](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview) with a Microsoft-managed ruleset. Apply the policy to all custom domains. Use Prevention mode to mitigate web attacks that might cause an origin service to become unavailable.
* Deployments with higher security requirements could also use [Private Link in Azure Front Door Premium](https://learn.microsoft.com/en-us/azure/frontdoor/private-link) to secure connectivity to Azure App Service.
For more recommendations and information, see [Best practices for Front Door](https://learn.microsoft.com/en-us/azure/frontdoor/best-practices).
## App Service 
* Access restrictions on Azure App Service should be configured to only allow Front Door traffic. Access restrictions ensure that requests aren't able to bypass the Azure Front Door WAF, see [App Service access restrictions](https://learn.microsoft.com/en-us/azure/app-service/app-service-ip-restrictions#restrict-access-to-a-specific-azure-front-door-instance).
* All service-to-service communication in Azure is TLS (transport layer security) encrypted by default. Azure Front Door and Azure App Services should be configured to accept HTTPS traffic only, and the minimum TLS version set.
* Managed identities are used for authenticating Azure service-to-service communication, where available. For more information about managed identities, see [What are managed identities for Azure resources?](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)

Check out [Defender for App Service](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-app-service-introduction) for secure and detect operations to protect your Azure App Service web apps and APIs.

## SQL Database
* Get to know the risks and [Common SQL threats](https://learn.microsoft.com/en-us/sql/relational-databases/security/sql-server-security-best-practices?view=sql-server-ver16#common-sql-threats) and plan how to [Protect](https://learn.microsoft.com/en-us/security/benchmark/azure/baselines/sql-database-security-baseline?toc=%2Fazure%2Fazure-sql%2Ftoc.json&view=azuresql).
* Define your encryption policy - you either use a Microsoft managed key or [BYOK](https://learn.microsoft.com/en-us/azure/azure-sql/database/transparent-data-encryption-byok-overview?view=azuresql).
* Verify your needs to protect and [detect](https://learn.microsoft.com/en-us/azure/azure-sql/database/threat-detection-configure?view=azuresql) any malfunction activity within your environment 
* Check out [Defender for Azure SQL](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-sql-introduction) to improve your vulnerabilities assessment  and threat protection processes.

For more recommendations and information, see [Azure SQL Security Baseline](https://learn.microsoft.com/en-us/security/benchmark/azure/baselines/sql-database-security-baseline?toc=%2Fazure%2Fazure-sql%2Ftoc.json&view=azuresql)

## Cache for Redis
* Set the publicNetworkAccess flag to Disabled to disable the public endpoint.
* To connect to a clustered cache, there can only be one private endpoint connection.

For more recommendations and information, see [Azure Redis Cache Security Baseline](https://learn.microsoft.com/en-us/security/benchmark/azure/baselines/azure-cache-for-redis-security-baseline)
# Deploy this scenario
Deploy this reference architecture using this [Azure sample on GitHub](/scenarios/secure-baseline-multitenant/README.md).

- Azure AD, Azure AD B2C, and Azure DNS aren't deployed by this sample.
- Custom domain names and TLS/SSL certificates aren't created and configured. Default frontend DNS names are used instead.
- The scripts are modular so you if you already have an existing environment, you can pick and choose the relevant section or adjust the relevant pieces according to your needs (deploy only SPOKE, replace SQL DB with PostgreSQL and etc.).


## Considerations for Azure Government cloud

Azure Front Door Premium is not available in Azure Government cloud.  The reference implementation will deploy an Azure Application Gateway instead.

## Next

Pick one of the IaC options below and follow the instructions to deploy the App Service reference implementation.

:arrow_forward: [Terraform](./terraform/README.md)

:arrow_forward: [Bicep](./bicep/README.md)

:arrow_forward: [ARM](./azure-resource-manager/README.md)
