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

- Review the reference implementation resources at [LOB-ILB-ASEv3](../../reference-implementations/LOB-ILB-ASEv3/) to better understand the specifics of this implementation.
- It is recommended that you clone this repo and modify the reference implementation resources to suit your requirements and your organization's specific landing zone guidelines.
- Ensure that the service principal used to deploy the solution has the required permissions to create the resource types listed above.
- Consider the CI/CD service you will use for deploying the reference implementation. As this reference implementation is an internal ASE, a self-hosted agent is needed to execute the deployment pipelines.  As such the choice is to use either a DevOps Agent or a GitHub Runner. Refer to the [user guide](../README.md) on specific configuration values required for each.
- Consider the region(s) to which you intend deploying this reference implementation, and consult the [ASEv3 Regions list](https://docs.microsoft.com/en-us/azure/app-service/environment/overview#regions) to ensure the selected region(s) are enabled for deployment.

## Scalability considerations

- Based on your scalability requirements, you may want to adjust the number of workers, and the size of the worker nodes, in the default App Service plan created by this reference implementation. These settings can be changed by cloning the repo and changing the `numberOfWorkers` and `workerPool` values in the relevant deployment files. For a Bicep deployment, for example, these values area available in the [ase.bicep](../../reference-implementations/LOB-ILB-ASEv3/bicep/ase.bicep) file.
- While this reference implementation does not implement a geo distributed scaling architecture, this capability is available as per [Geo Distributed Scale with App Service Environments](https://docs.microsoft.com/en-us/azure/app-service/environment/app-service-app-service-environment-geo-distributed-scale)
- For other scalability topics, see the [performance efficiency checklist](https://docs.microsoft.com/en-us/azure/architecture/framework/scalability/performance-efficiency) available in the Azure Architecture Center.

## Availability considerations

- Consider your requirements for zone redundancy in this reference implementation, as well as the zone redundancy capabilities of any other Azure Services in your solution. ASEv3 supports zone redundancy by spreading instances to all three zones in the target region. This can only be set at the time of ASE creation, and may not be available in all regions. See [Availability zone support for App Service Environment](https://docs.microsoft.com/en-us/azure/app-service/environment/overview-zone-redundancy) for more detail. This reference implementation does implement  zone redundancy, but this can be changed by cloning this repo and setting the `zoneRedundant` property to `false`.
- When deploying an ASE across availability zones, use Azure Application Gateway to provide load balancing and WAF (Web Application Firewall) capabilities between the zonal instances.
- If you need to recover from a disaster, consider the appropriate DR strategy, based on your specific RTO and RPO requirements. When evaluating a redeployment of the ASE as a potential strategy, be sure to account for the time taken to create a new ASE and to deploy your App Service solutions to this ASE, as collectively this can take a number of hours to complete.  Also consider the other components that need to be accounted for in the overall DR strategy (e.g. Azure SQL, Azure CosmosDB, etc)
- For additional considerations concerning availability, see the [availability checklist](https://docs.microsoft.com/en-us/azure/architecture/framework/resiliency/reliability-patterns) in the Azure Architecture Center.
- If an Application Gateway is used along with [App Service](https://docs.microsoft.com/en-us/azure/app-service/networking/app-gateway-with-service-endpoints) or [App Service Environment](https://docs.microsoft.com/en-us/azure/app-service/environment/integrate-with-application-gateway#:~:text=The%20integration%20of%20the%20application%20gateway%20with%20the,specific%20apps%20in%20your%20ILB%20App%20Service%20Environment.), consider Recovery Point Objective (RPO) and Recovery Time Objective(RTO) requirements, as those will dictate if App Gateway needs to be deployed in:
    - Single or Multi Region
    - Active-Active or Active-Standby Configuration
- Consider whether a single point of entry or multiple entry points are required based on where the requests are coming from. This will facilitate decision for [Traffic Manager](https://docs.microsoft.com/en-us/azure/traffic-manager/traffic-manager-overview) or [Azure Front Door](https://docs.microsoft.com/en-us/azure/frontdoor/front-door-overview)
    - Is cost a concern?
    - Is latency or an extra hop a concern?
    - Any third-party solution used to direct traffic to App Gateway? 
- Backup of App Gateway configuration – Only ARM Template? Where is it stored and how it’ll be utilized – Manually or through automation e.g., ADO pipelines?
- Consider the [information that can be backed up](https://docs.microsoft.com/en-us/azure/app-service/manage-backup#what-gets-backed-up) and the [requirements and restrictions](https://docs.microsoft.com/en-us/azure/app-service/manage-backup#requirements-and-restrictions)

### Multi-Tenanted:

- If your application needs to be redundant across regions, deploy the solution in more than one region and use Traffic Manager or Azure Front Door to balance load between these deployments.
- If your application span geographies, consider deploying to a single region in each applicable geography and use Traffic Manager or Azure Front Door to provide geography-based routing.  This will provide enhanced performance and increased redundancy.
- If you need to recover from a disaster, consider if redeploying the application from a CI/CD process would be adequate.  Also consider that a web app is a component in a larger solution, and you will need to consider the DR processes for the other components in the solution.

### App Service Environment:

- Guidance on architecting an [ASE-based solution for high availability within a region](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/enterprise-integration/ase-high-availability-deployment)
- Guidance on [geographic redundancy](https://docs.microsoft.com/en-us/azure/app-service/environment/app-service-app-service-environment-geo-distributed-scale) 

## Manageability considerations

- Ensure that App Services deployed to the ASE are configured to utilize Application Insights to monitor the App Services and to assist in operational reporting and troubleshooting.
- Configure alerts using Azure Monitor and Application Insights data to raise awareness of issues pertaining to availability, performance, user experience, and scalability pressures. Review [Monitoring App Service](https://docs.microsoft.com/en-us/azure/app-service/monitor-app-service) and [Monitor apps in Azure App Service](https://docs.microsoft.com/en-us/azure/app-service/web-sites-monitor) for more details and guidance.
- Consider the number of App Service Environments you will need (e.g. Dev, UAT, Production), and also consider which of these should be upgraded before others, as per the [ASE upgrade preference options](https://docs.microsoft.com/en-us/azure/app-service/environment/using#upgrade-preference).  Dev environments should be configured using the `Early` value, while Production environments should be configured with the `Late` value.
- Use a different Application Insights instance for each environment, and potentially for each solution within an environment, to ensure no cross-pollination of telemetry data.
- Use App Service Diagnostics to gain a greater understanding of your app service’s behavior in times of instability and/or performance problems.
- Consider the [App Service deployment best practices](https://docs.microsoft.com/en-us/azure/app-service/deploy-best-practices) to ensure robust CI/CD processes that will help ease the manageability tasks associated with deployment of changes and new functionality to an App Service running on an ASE.
- Consider using prefixes and suffixes with well-defined conventions to uniquely identify every deployed resource. These naming conventions avoid conflicts when deploying solutions next to each other and improve overall team agility and throughput.
- Consider deploying other resources like subscriptions, tagging, and labels to support your DevOps experience by tracking and tracing deployments and related artifacts.
- Depending on the network configuration, App Services might not be reachable from the public internet and the use of public hosted agents will not work for deployments. Plan to use [self-hosted agents](https://azure.github.io/AppService/2021/01/04/deploying-to-network-secured-sites.html) in that scenario.
- Consider deploying containerized applications to take advantage of simplified deployments using Docker Hub or Azure Container Registry.
- Adopt a branching strategy which will help you collaborate while providing flexibility as well. Keep your strategy simple, use short-living feature isolation and allow modifications back to your main branch through pull requests with manual and automated code analysis.
- Make sure that your business logic is checked by unit tests in the build pipeline. Use integration tests in the release pipeline to check that every service and resource work together after a new release and check the most critical UI elements with automated UI tests. Cover non-functional performance requirements with load tests (eg k6, JMeter) in your staging environment.
Be aware of [App Service limits](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#app-service-limits). Scale up or use multiple App Service instances to scale beyond those limits. Performance testing should be completed prior to gain a proper understanding of sizing and instance count for the [App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans).
- Consider if scaling out/up of the App Service Plan is beneficial for your scenario.  If so, [automate the scale-out and scale-in](https://docs.microsoft.com/en-us/azure/azure-monitor/autoscale/autoscale-best-practices#manual-scaling-is-reset-by-autoscale-min-and-max) with auto-scaling rules. 
- Leverage [Availability Tests](https://docs.microsoft.com/en-us/azure/azure-monitor/app/availability-overview) and set alerts on them to help determine when your app service is not reachable. 
- Alerts are a proactive way for you to identify and begin troubleshooting problems before you hear from the user, but can also contribute noise to the environment. Therefore, test your scenario to find an acceptable level of alerting.  Also, be aware of the [limitation on alert rules](https://docs.microsoft.com/en-us/azure/azure-monitor/service-limits).
- For App Service Environments, consider configuring [Upgrade Preference](https://docs.microsoft.com/azure/app-service/environment/using-an-ase#upgrade-preference) if multiple environments are used. 

## Security considerations

- Since this reference implementation deploys an ASE into a virtual network (referred to as an internal ASE), all applications deployed to the ASE are inherently network-isolated at the scope of the virtual network.
- Applications deployed to the same ASE therefore share the same network and can see each other. Principles of [Zero Trust security](https://docs.microsoft.com/en-us/azure/security/fundamentals/zero-trust) should be considered to ensure that each App Service deployed to the ASE enforces its own authentication and authorization requirements.
- When configuring networking rules for the ASE virtual network, consider that all App Services deployed to the ASE will be affected by the same rules. Further restrictions can be applied to the individual App Services, where necessary.
- Ensure that secrets and certificates used in the App Services deployed to the ASE are stored in and referenced from the associated Azure Key Vault instance.
- Use the built-in Azure RBAC (role-based access control) to ensure that the principle of least privilege access is applied to any Operations users that have access to the ASE.
- Use system-assigned managed identities to ensure that the App Services deployed to the ASE access any AAD-protected backend resources securely.
- Review and follow the recommendations outlined in the [Azure security baseline for App Service](https://docs.microsoft.com/en-us/security/benchmark/azure/baselines/app-service-security-baseline).
- For additional considerations concerning security of App Services, see [App Service security recommendations](https://docs.microsoft.com/en-us/azure/app-service/security-recommendations)
- When securing and protecting access to development, test, Q&A, and production environments, consider security options from a CI/CD perspective. Deployments happen automatically, so map access control accordingly.
- Decide on the type of access for your application: public, private, or both.
- Decide on how to authenticate users that need to access your App Service: anonymous, internal corporate users, social accounts, other [identity provider](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity?tabs=dotnet), or a mixture of these.
- Decide on whether to use system-assigned or user-assigned [managed identities](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity?tabs=dotnet) for your App Service when connecting to AAD-protected backend resources.
- Consider creating [custom roles](https://docs.microsoft.com/en-us/azure/active-directory/roles/custom-create) following the principle of least privilege when out-of-box roles require modifications on existing permissions. Utilize [App Configuration](https://docs.microsoft.com/en-us/azure/architecture/solution-ideas/articles/appconfig-key-vault) to share common configuration values between applications, microservices, and serverless applications that are not passwords, secrets, or keys.
- Consider what level of logging is necessary to meet your organization’s compliance requirements. 
- Review your security requirements to determine if they allow your web applications to be run on shared network infrastructure or if they require the complete network/virtual machine isolation available with [App Service Environments](https://docs.microsoft.com/en-us/azure/app-service/environment/overview). 
- Review which Web Application Firewall [rulesets](https://docs.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules?tabs=owasp32) and/or custom rules are necessary to meet your security and compliance requirements.
- Evaluate the security of your software supply chain and determine the tools and processes in place to automatically patch application dependency vulnerabilities and reliably deploy them into your environment.

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