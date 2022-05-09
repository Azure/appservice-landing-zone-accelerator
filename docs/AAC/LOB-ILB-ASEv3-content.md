> The H1 title is the same as the title metadata. Don't enter it here, but as the **name** value in the corresponding YAML file.

_Brief introduction goes here._ [**Deploy this solution**.](#deploy-the-solution)

![alt text.](./media/folder_name/architecture-diagram.png)

_Download a [Visio file](https://arch-center.azureedge.net/architecture.vsdx) that contains this architecture diagram. This file must be uploaded to `https://arch-center.azureedge.net/`_

## Architecture

Include visio diagram

### Components

The solution uses the following Azure services:

- **[App Service Environment v3 (ASEv3)](https://docs.microsoft.com/en-us/azure/app-service/environment/overview)** is a single tenant  service for customers that require high scale, network isolation and security, and/or high memory utilization. Apps are hosted in [App Service plans](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans) created in ASEv3 with options of using different tiers within an Isolated v2 Service Plan. Compared to earlier version of ASE numerous improvements have been made including, but not limited to, network dependency, scale time, and the removal of the stamp fee. This reference architecture uses an internal App Service Environment v3. 
  
 - **[Azure Private DNS Zones](https://docs.microsoft.com/en-us/azure/dns/private-dns-privatednszone)** allow users to manage and resolve domain names within a virtual network without needing to implement a custom DNS solution. A Private Azure DNS zone can be aligned to one or more virtual networks through [virtual network links](https://docs.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links). Due to the internal nature of the ASEv3 this reference architecture uses, a private DNS zone is required to resolve the domain names of applications hosted on the App Service Environment.

- **[Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)** is a feature of Azure Monitor that helps Developers detect anomalies, diagnose issues, and understand usage patterns with extensible application performance management and monitoring for live web apps. A variety of platforms including .NET, Node.js, Java, and Python are supported for apps that are hosted in Azure, on-prem, hybrid, or other public clouds. Application Insights is included as part of this reference architecture to monitor behaviors of the deployed application.

- **[Log Analytics](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview)** is a feature of Azure Monitor that allows users to edit and run log queries with data in Azure Monitor Logs, optionally from within the Azure portal. Developers can run simple queries for a set of records or use Log Analytics to perform advanced analysis and visualize the results. Log Analytics is configured as part of this reference architecture to aggregate all the monitoring logs for additional analysis and reporting.

- **[Azure Virtual Machine](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/overview)** is an on-demand, scalable computing resource that can be used to host a number of different workloads. In this reference architecture, virtual machines are used to provide a management jumpbox server, as well as a host for the DevOps Agent / GitHub Runner. 

- **[Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/general/basic-concepts)** is a cloud service to securely store and access secrets ranging from API keys and passwords to certificates and cryptographic keys. While this reference architecture does not store secrets in the Key Vault as part of the infrastructure deployment of this reference architecture, the Key Vault is deployed to facilitate secret management for future code deployments. 

- **[Azure Bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview)** is a Platform-as-a-Service service provisioned within the developer's virtual network which provides secure RDP/SSH connectivity to the developer's virtual machines over TLS from the Azure portal. With Azure Bastion, virtual machines no longer require a public IP address to connect via RDP/SSH. This reference architecture uses Azure Bastion to access the DevOps Agent / GitHub Runner server or the management jumpbox server. 


## Recommendations

The following recommendations apply for most scenarios. Follow these recommendations unless you have a specific requirement that overrides them.

_Include considerations for deploying or configuring the elements of this architecture._

- Review the reference implementation resources at [LOB-ILB-ASEv3](../../reference-implementations/LOB-ILB-ASEv3/) to better understand the specifics of this implementation.
- It is recommended that you clone this repo and modify the reference implementation resources to suit your requirements and your organization's specific landing zone guidelines.
- Ensure that the service principal used to deploy the solution has the required permissions to create the resource types listed above.
- Consider the CI/CD service you will use for deploying the reference implementation. As this reference implementation is an internal ASE, a self-hosted agent is needed to execute the deployment pipelines.  As such the choice is to use either a DevOps Agent or a GitHub Runner. Refer to the [user guide](../README.md) on specific configuration values required for each.
- Consider the region(s) to which you intend deploying this reference implementation, and consult the [ASEv3 Regions list](https://docs.microsoft.com/en-us/azure/app-service/environment/overview#regions) to ensure the selected region(s) are enabled for deployment.

## Identity and Access Management
[Design Recommendations](/docs/Design-Areas/identity-access-mgmt.md)

### Design Considerations
- Decide on the type of access for your application: public, private, or both.
- Decide on how to authenticate users that need to access your App Service: anonymous, internal corporate users, social accounts, other [identity provider](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity?tabs=dotnet), or a mixture of these.
- Decide on whether to use system-assigned or user-assigned [managed identities](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity?tabs=dotnet) for your App Service when connecting to AAD-protected backend resources.
- Consider creating [custom roles](https://docs.microsoft.com/en-us/azure/active-directory/roles/custom-create) following the principle of least privilege when out-of-box roles require modifications on existing permissions. Utilize [App Configuration](https://docs.microsoft.com/en-us/azure/architecture/solution-ideas/articles/appconfig-key-vault) to share common configuration values between applications, microservices, and serverless applications that are not passwords, secrets, or keys.
### Design Recommendations
- If the App Service requires authentication:
    - If access to the entire app service needs to be restricted to authenticated users, disable anonymous access.
    - Use the [Easy Auth](https://docs.microsoft.com/en-us/azure/app-service/overview-authentication-authorization) capabilities of App Services, instead of writing your own authentication and authorization code.
    - Use separate [application registrations](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app) for separate [slots](https://docs.microsoft.com/en-us/azure/app-service/deploy-staging-slots) or environments.
    - If the App Service is intended for internal users only, use [client certificate authentication](https://docs.microsoft.com/en-us/azure/app-service/deploy-staging-slots) for increased security.
    - If the App Service is intended for external users, utilize [Azure AD B2C](https://docs.microsoft.com/en-us/azure/active-directory-b2c/overview) to authenticate to social accounts and Azure AD accounts. 
- Use [Azure built-in roles](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#web-plan-contributor) to provide least privilege permissions to manage App Service Plans and Websites
- Utilize system-assigned [managed identities](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity?tabs=dotnet) to securely access AAD-protected backend resources.
- Ensure that users with access to Production resources in Azure are controlled and limited.
- For automated deployment purposes, setup a [service principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals) that has the minimum required permissions to deploy from the pipeline
- Review and follow the recommendations outlined in the [Identity and Access Control section](https://docs.microsoft.com/en-us/security/benchmark/azure/baselines/app-service-security-baseline?toc=/azure/app-service/toc.json#identity-and-access-control) of the Azure security baseline for App Service.

## Network Topology and Connectivity
[Design Recommendations](/docs/Design-Areas/networking.md)

### Design Considerations
- Consider your networking requirements and [use cases](https://docs.microsoft.com/en-us/azure/app-service/networking-features#use-cases-and-features), and whether the application is to be exposed to internal users or external users or both, and the appropriate [App Service Plan tier](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#app-service-limits) that will be required to support those networking requirements.   

#### Multi-Tenanted:
- App Services in the multi-tenanted service share a single inbound and multiple outbound IP addresses with other App Services in the same deployment unit.  These can change for a [variety of reasons](https://docs.microsoft.com/en-us/azure/app-service/overview-inbound-outbound-ips#how-ip-addresses-work-in-app-service). If consistent outbound IP addresses are needed for multi-tenant App Service, a [NAT gateway](https://docs.microsoft.com/en-us/azure/app-service/networking/nat-gateway-integration#:~:text=%20Set%20up%20NAT%20gateway%20through%20the%20portal%3A,Basics%20information%20and%20pick%20the%20region...%20More%20) can be configured, or[ VNet  Integration](https://docs.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet) can be used.
- If a dedicated IP address is required by which to address your App Service, you can make use of [App-assigned addresses](https://docs.microsoft.com/en-us/azure/app-service/networking-features#app-assigned-address), or you could front your App Service with an [Application Gateway](https://docs.microsoft.com/en-us/azure/app-service/networking/app-gateway-with-service-endpoints) (which is assigned a static IP address).
- When there is a need to connect from an App Service to on-prem, private, or IP-restricted services, consider that:
    - When running in the multi-tenanted environment, the App Service call can originate from a wide range of IP addresses, and [VNet Integration](https://docs.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet) may be needed.
    - Services like [API Management (APIM)](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts) could be used to proxy calls between networking boundaries and can provide a static IP if needed.
- App Services in the multi-tenanted environment can be deployed with a private or a public endpoint.  When deployed with a [Private Endpoint](https://docs.microsoft.com/en-us/azure/app-service/networking/private-endpoint), public exposure of the App Service is eliminated.  If there is a requirement for the private endpoint of the App Service to also be reachable via the Internet, consider the use of App Gateway to expose the app service. 
 - The multi-tenanted App Service exposes [a set of ports](https://docs.microsoft.com/en-us/azure/app-service/networking-features#app-service-ports), and these cannot be changed or blocked.
- Plan your subnets correctly for outbound VNET integration and consider the number of IP addresses that are required. VNet Integration depends on a dedicated subnet. When you provision a subnet, the Azure subnet loses five IPs from the start. One address is used from the integration subnet for each plan instance. When you scale your app to four instances, then four addresses are used. When you scale up or down in size, the required address space is doubled for a short period of time. This affects the real, available supported instances for a given subnet size.
 
#### App Service Enviornment:
- App Services deployed on an ASE get static, dedicated IP addresses for inbound and outbound communication, for the lifetime of the ASE.
- When there is a need to connect from an App Service to on-prem, private, or IP-restricted services, consider that:
    - When running in an ASE, the App Service is running within the context of a VNet.
    - A service like API Management (APIM) could be used to proxy calls between networking boundaries and can provide a static IP if needed.
- Consider whether your app services on an ASE needs to be exposed externally or if they only need to be exposed on the private network.
- The size of the subnet you select when deploying an ASE cannot be changed later, so be sure to consider your maximum scale needs.


### Design Recommendations
- Connecting to an App Service:
    - Ensure you have a [Web Application Firewall](https://docs.microsoft.com/en-us/azure/web-application-firewall/overview) (WAF) implemented in front of your App Service, using [Azure Front Door](https://docs.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview), [Azure Application Gateway](https://docs.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview), or a third-party service, to provide OWASP-based protection. You can use either Front Door or App Gateway for a single region, or both if you are doing multi-region. If you need path routing within the region, you would need App Gateway, and if you need multi-region load balancing and WAF, you would need Front Door.
    - Employ the appropriate use of access restrictions so that the app service is only reachable from valid locations. For example, if the app service is hosting APIs, and is fronted by APIM, setup an access restriction so that the app service is only accessible from APIM.
- Connecting from an App Service:
    - Where private connectivity to other Azure services is required, use [Private Link](https://docs.microsoft.com/en-us/azure/private-link/private-link-overview) if [supported by those services](https://docs.microsoft.com/en-us/azure/private-link/availability).  
- Use the [built-in tools](https://azure.github.io/AppService/2021/04/13/Network-and-Connectivity-Troubleshooting-Tool.html) for troubleshooting any networking issues
- Avoid [SNAT port exhaustion](https://docs.microsoft.com/en-us/azure/app-service/troubleshoot-intermittent-outbound-connection-errors) by utilizing connection pools.  The creation of new connections repetitively to the same host and port can cause slow response times, intermittent 5xx errors, timeouts, or external endpoint connection issues.
- Review and follow the recommendations outlined in the [Network Security section](https://docs.microsoft.com/en-us/security/benchmark/azure/baselines/app-service-security-baseline?toc=/azure/app-service/toc.json#network-security) of the Azure security baseline for App Service.
#### Multi-Tenanted:
- If you need a dedicated outbound address when connecting to an multi-tenanted App Service, use a [NAT Gateway](https://docs.microsoft.com/en-us/azure/app-service/networking/nat-gateway-integration). 
- Since subnet size can't be changed after assignment, use a subnet that's large enough to accommodate whatever scale your app might reach. To avoid any issues with subnet capacity, you should use a /26 with 64 addresses for Vnet integration.
#### App Service Enviornment:
- Your subnet should be sized with a /24 CIDR range, providing 256 addresses. 

## Management and Monitoring
[Design Recommendations](/docs/Design-Areas/mgmt-monitoring.md)

### Design Consideration
- Be aware of [App Service limits](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#app-service-limits). Scale up or use multiple App Service instances to scale beyond those limits. Performance testing should be completed prior to gain a proper understanding of sizing and instance count for the [App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans).
- Consider if scaling out/up of the App Service Plan is beneficial for your scenario.  If so, [automate the scale-out and scale-in](https://docs.microsoft.com/en-us/azure/azure-monitor/autoscale/autoscale-best-practices#manual-scaling-is-reset-by-autoscale-min-and-max) with auto-scaling rules. 
- Leverage [Availability Tests](https://docs.microsoft.com/en-us/azure/azure-monitor/app/availability-overview) and set alerts on them to help determine when your app service is not reachable. 
- Alerts are a proactive way for you to identify and begin troubleshooting problems before you hear from the user, but can also contribute noise to the environment. Therefore, test your scenario to find an acceptable level of alerting.  Also, be aware of the [limitation on alert rules](https://docs.microsoft.com/en-us/azure/azure-monitor/service-limits).
- For App Service Environments, consider configuring [Upgrade Preference](https://docs.microsoft.com/azure/app-service/environment/using-an-ase#upgrade-preference) if multiple environments are used. 
### Design Recommendation 
- Use [Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview) or another Application Performance Management solution to monitor  and learn how your application behaves in different environments.
    - Two ways to [enable App Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/azure-web-apps) currently exist.
    - For different environments collect telemetry data into different Application Insights instances.
    - If your application has multiple components separated into different services but you would like to examine their behavior together, then collect their telemetry data into same Application Insights instance but label them with different cloud role names.
    - Export Application Insights data to an [Azure Log Analytics](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview) Workspace. A single Workspace for the organization is recommended.
    - Include operational dashboards in application and feature design to ensure the solution can be supported in production.
    - Implement health checks for your endpoints and use them for health probes, dependency checks and availability tests.
- For stateless app services, disable ARR Affinity
- For a high-level overview of your app service’s performance, use Azure Monitor [Dashboards](https://docs.microsoft.com/en-us/azure/azure-monitor/visualizations#azure-dashboards)
- Use the [built-in application monitoring](https://docs.microsoft.com/en-us/azure/azure-monitor/app/azure-web-apps) 
- Use [AutoHeal](https://docs.microsoft.com/en-us/azure/azure-monitor/app/azure-web-apps) (proactive or custom) to gather helpful data for performance or stability issue
- Use [App Service Diagnostics](https://docs.microsoft.com/en-us/azure/app-service/overview-diagnostics) to gain a greater understanding of your app service’s behavior in times of instability and/or performance problems.
- Enable [diagnostic logging](https://docs.microsoft.com/en-us/azure/app-service/troubleshoot-diagnostic-logs) and be aware a storage account may be necessary to store the log files.
- Configure centralized log management solution and integrate your app services to send logs there
- Ensure that every defined alert also has a defined response.
- Use deployment slots for resilient code deployments and to avoid unnecessary Worker restarts (some triggers include content deployment, app setting changes, VNet integration configuration changes, etc.)
- Use [run from package](https://docs.microsoft.com/azure/app-service/deploy-run-package) to avoid deployment conflicts.

## Business Continuity and Disaster Recovery
[Design Recommendations](/docs/Design-Areas/BCDR.md)

### Design Considerations
- If an Application Gateway is used along with [App Service](https://docs.microsoft.com/en-us/azure/app-service/networking/app-gateway-with-service-endpoints) or [App Service Environment](https://docs.microsoft.com/en-us/azure/app-service/environment/integrate-with-application-gateway#:~:text=The%20integration%20of%20the%20application%20gateway%20with%20the,specific%20apps%20in%20your%20ILB%20App%20Service%20Environment.), consider Recovery Point Objective (RPO) and Recovery Time Objective(RTO) requirements, as those will dictate if App Gateway needs to be deployed in:
    - Single or Multi Region
    - Active-Active or Active-Standby Configuration
- Consider whether a single point of entry or multiple entry points are required based on where the requests are coming from. This will facilitate decision for [Traffic Manager](https://docs.microsoft.com/en-us/azure/traffic-manager/traffic-manager-overview) or [Azure Front Door](https://docs.microsoft.com/en-us/azure/frontdoor/front-door-overview)
    - Is cost a concern?
    - Is latency or an extra hop a concern?
    - Any third-party solution used to direct traffic to App Gateway? 
- Backup of App Gateway configuration – Only ARM Template? Where is it stored and how it’ll be utilized – Manually or through automation e.g., ADO pipelines?
- Consider the [information that can be backed up](https://docs.microsoft.com/en-us/azure/app-service/manage-backup#what-gets-backed-up) and the [requirements and restrictions](https://docs.microsoft.com/en-us/azure/app-service/manage-backup#requirements-and-restrictions)
#### Multi-Tenanted:
- If your application needs to be redundant across regions, deploy the solution in more than one region and use Traffic Manager or Azure Front Door to balance load between these deployments.
- If your application span geographies, consider deploying to a single region in each applicable geography and use Traffic Manager or Azure Front Door to provide geography-based routing.  This will provide enhanced performance and increased redundancy.
- If you need to recover from a disaster, consider if redeploying the application from a CI/CD process would be adequate.  Also consider that a web app is a component in a larger solution, and you will need to consider the DR processes for the other components in the solution.
#### App Service Environment:
- Guidance on architecting an [ASE-based solution for high availability within a region](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/enterprise-integration/ase-high-availability-deployment)
- Guidance on [geographic redundancy](https://docs.microsoft.com/en-us/azure/app-service/environment/app-service-app-service-environment-geo-distributed-scale) 

### Design Recommendations
#### Multi-Tenanted:
- Deploy your App Service solution to at least 2 regions, and possibly to multiple geographies, if required.
- Utilize Azure Front Door to provide load balancing and WAF capabilities between the different deployments.
- Modify your CI/CD processes so that changes to the solution are deployed to each target region.
- Ensure that your CI/CD processes are setup to re-deploy the solution in case a disaster impacts one or more of the deployments.
#### App Service Environment:
- Deploy one instance of the ASE in 2 separate Availability Zones in the same region, or in 2 different regions if cross-regional high availability is required.
- Where your ASE instances are deployed across Availability Zones in the same region, use Azure Application Gateway to provide load balancing and WAF capabilities between the instances.
- Where cross-regional high availability is required, utilize Azure Front Door to provide load balancing and WAF capabilities between the different instances.
- Modify your CI/CD processes so that changes to the solution are deployed to each target ASE instance.

## Security, Governance, and Compliance
[Design Recommendations](/docs/Design-Areas/security-governance-compliance.md)

### Design Considerations
- Consider what level of logging is necessary to meet your organization’s compliance requirements. 
- Review your security requirements to determine if they allow your web applications to be run on shared network infrastructure or if they require the complete network/virtual machine isolation available with [App Service Environments](https://docs.microsoft.com/en-us/azure/app-service/environment/overview). 
- Review which Web Application Firewall [rulesets](https://docs.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules?tabs=owasp32) and/or custom rules are necessary to meet your security and compliance requirements.
- Evaluate the security of your software supply chain and determine the tools and processes in place to automatically patch application dependency vulnerabilities and reliably deploy them into your environment.
### Design Recommendations
- Use [Private Endpoint](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview) to privately access [Azure services](https://docs.microsoft.com/en-us/azure/private-link/availability) through your vNet 
- Use [Azure Policy](https://docs.microsoft.com/en-us/azure/app-service/policy-reference) to assess and enforce Regulatory Compliance controls
- Apps should only be accessible over HTTPS.
- Use the latest TLS version when encrypting information in transit.
- Review the list of SSL cyphers.
- Store application secrets (database credentials, API tokens, private keys) in Azure Key Vault and configure your App Service app to access them securely with a Managed Identity.  Determine [when to use Azure Key Vault vs Azure App Configuration](https://docs.microsoft.com/en-us/azure/architecture/solution-ideas/articles/appconfig-key-vault) with the guidance in mind. 
- [Enable Cross-Origin Resource Sharing (CORS)](https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-rest-api#enable-cors) within App Services or using your own CORS utilities to indicate which origins the user’s browser should permit resources to be loaded from.
- When deploying containerized web applications to App Services, [enable Azure Defender for container registries](https://docs.microsoft.com/en-us/azure/security-center/defender-for-container-registries-introduction) to automatically scan images for vulnerabilities.
- Enable[ Azure Defender for App Service](https://docs.microsoft.com/en-us/azure/security-center/defender-for-app-service-introduction#:~:text=%20When%20you%20enable%20Azure%20Defender%20for%20App,App%20Service%20resources%20by%20monitoring%3A%0Athe%20VM...%20More%20) to assess the security of your web applications and detect threats to your App Service resources.
- 
## Application Automation and DevOps
[Design Recommendations](/docs/Design-Areas/automation-devops.md)

### Design Considerations
- When securing and protecting access to development, test, Q&A, and production environments, consider security options from a CI/CD perspective. Deployments happen automatically, so map access control accordingly.
- Consider using prefixes and suffixes with well-defined conventions to uniquely identify every deployed resource. These naming conventions avoid conflicts when deploying solutions next to each other and improve overall team agility and throughput.
- Consider deploying other resources like subscriptions, tagging, and labels to support your DevOps experience by tracking and tracing deployments and related artifacts.
- Depending on the network configuration, App Services might not be reachable from the public internet and the use of public hosted agents will not work for deployments. Plan to use [self-hosted agents](https://azure.github.io/AppService/2021/01/04/deploying-to-network-secured-sites.html) in that scenario.
- Consider deploying containerized applications to take advantage of simplified deployments using Docker Hub or Azure Container Registry.
- Adopt a branching strategy which will help you collaborate while providing flexibility as well. Keep your strategy simple, use short-living feature isolation and allow modifications back to your main branch through pull requests with manual and automated code analysis.
- Make sure that your business logic is checked by unit tests in the build pipeline. Use integration tests in the release pipeline to check that every service and resource work together after a new release and check the most critical UI elements with automated UI tests. Cover non-functional performance requirements with load tests (eg k6, JMeter) in your staging environment.

### Design Recommendations
- Rely on pipelines or actions to:
    - Maximize applied practices across the team.
    - Remove much of the burden of reinventing the wheel.
    - Provide predictability and insights in overall quality and agility.
- Deploy early and often by using trigger-based and scheduled pipelines. Trigger-based pipelines ensure changes go through proper validation, while scheduled pipelines manage behavior in changing environments.
- Separate infrastructure deployment from application deployment. Core infrastructure changes less than applications. Treat each type of deployment as a separate flow and pipeline.
- Store secrets and other sensitive artifacts in the relevant secret store (eg Azure Key Vault or GitHub secrets), allowing actions and other workflow parts to read them if needed while executing.
-  Strive for maximized deployment concurrency by avoiding hardcoded configuration items and settings.
-  Embrace [shift left](https://docs.microsoft.com/en-us/azure/devops/learn/devops-at-microsoft/shift-left-make-testing-fast-reliable) security by adding vulnerability and secret scanning tools like container scanning early in the pipeline.
- Leverage blue/green deployment using deployment slots to validate application changes and minimize downtime. 

## Cost Considerations

- While there is no stamp fee for an ASEv3 instance, there is a charge levied when there are no App Service Plans configured within the ASEv3 instance. This charge is levied at the same rate as one instance of a Windows I1v2 instance for the region in which the ASEv3 instance is deployed.
- When configured to be zone redundant, the charging model is adjusted to account for the underlying infrastructure deployed in this configuration, and you may therefore be liable for additional instances, as per [ASEv3 Pricing](https://docs.microsoft.com/en-us/azure/app-service/environment/overview#pricing)
- Reserved instance pricing for ASEv3 App Service Plans (aka Isolated v2 App Service Plans) as per [How reservation discounts apply to Isolated v2 instances](https://docs.microsoft.com/en-us/azure/cost-management-billing/reservations/reservation-discount-app-service#how-reservation-discounts-apply-to-isolated-v2-instances)

## Deploy this scenario

A deployment for the reference architecture that implements these recommendations and considerations is available on [GitHub](https://github.com/Azure/appservice-landing-zone-accelerator/tree/main/reference-implementations/LOB-ILB-ASEv3).



## Next steps

* [Security in Azure App Service](/azure/app-service/overview-security)
* [Networking for App Service](/azure/app-service/networking-features)

## Related resources


* [High availability enterprise deployment using App Services Environment](docs/reference-architectures/enterprise-integration/ase-high-availability-deployment.yml)
* [Enterprise deployment using App Services Environment](docs/reference-architectures/enterprise-integration/ase-standard-deployment.yml)
