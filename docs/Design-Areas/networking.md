# Network Topology and Connectivity
## Design Considerations
### Multi-Tenanted:
- Consider your networking requirements, and whether the application is to be exposed to internal users or external users or both, and the appropriate App Service Plan tier that will be required to support those networking requirements.  See [detailed matrix](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#app-service-limits) of features supported per App Service Plan tier.
- App Services in the multi-tenanted service share a single inbound and multiple outbound IP addresses with other App Services in the same deployment unit.  These can change for a [variety of reasons](https://docs.microsoft.com/en-us/azure/app-service/overview-inbound-outbound-ips#how-ip-addresses-work-in-app-service). If consistent outbound IP addresses are needed for multi-tenant app service, a NAT gateway can be configured, or VNet  Integration can be used.
- If you require a dedicated IP address by which to address your App Service, you can make use of App-assigned addresses, or you could front your App Service with an App Gateway (which is assigned a static IP address).
- When there is a need to connect from an App Service to on-prem, private, or IP-restricted services, consider that:
    - When running in the multi-tenanted environment, the App Service call can originate from a wide range of IP addresses, and VNet Integration may be needed.
    -  service like API Management (APIM) could be used to proxy calls between networking boundaries and can provide a static IP if needed.
- App Services in the multi-tenanted environment can be deployed with a private or a public endpoint.  When deployed with a Private Endpoint, public exposure of the App Service is eliminated.  If there is a requirement for the private endpoint of the App Service to also be reachable via the Internet, consider the use of App Gateway to expose the app service. 
- Review the [mapping of networking features to use cases](https://docs.microsoft.com/en-us/azure/app-service/networking-features#use-cases-and-features). 
 - The multi-tenanted App Service exposes [a set of ports](https://docs.microsoft.com/en-us/azure/app-service/networking-features#app-service-ports), and these cannot be changed or blocked.
- Plan your subnets correctly for outbound VNET integration and consider the number of IP addresses that are required. VNet Integration depends on a dedicated subnet. When you provision a subnet, the Azure subnet loses five IPs from the start. One address is used from the integration subnet for each plan instance. When you scale your app to four instances, then four addresses are used. When you scale up or down in size, the required address space is doubled for a short period of time. This affects the real, available supported instances for a given subnet size.
 
### App Service Enviornment:
- App Services deployed on an ASE get static, dedicated IP addresses for inbound and outbound communication, for the lifetime of the ASE.
- When there is a need to connect from an App Service to on-prem, private, or IP-restricted services, consider that:
    - When running in an ASE, the App Service is running within the context of a VNet.
    - A service like API Management (APIM) could be used to proxy calls between networking boundaries and can provide a static IP if needed.
- Consider whether your app services on an ASE needs to be exposed externally or if they only need to be exposed on the private network.
- The size of the subnet you select when deploying an ASE cannot be changed later, so be sure to consider your maximum scale needs.
- Review the [mapping of networking features to use cases](https://docs.microsoft.com/en-us/azure/app-service/networking-features#use-cases-and-features). 

## Design Recommendations
Recommended design choices when using App Services in a multi-tenanted (MT) or App Service Environment (ASE) enterprise-scale deployment:
### Multi-Tenanted:
- Connecting from an App Service:
    - Where private connectivity to other Azure services is required, use Private Link if supported by those services.  Please refer to the [list of services that support Private Link](https://docs.microsoft.com/en-us/azure/private-link/availability).
    - If you need a dedicated outbound address, consider the use of a [NAT Gateway](https://docs.microsoft.com/en-us/azure/azure-functions/functions-how-to-use-nat-gateway).
- Connecting to an App Service:
    - Ensure you have a Web Application Firewall (WAF) implemented in front of your App Service, using Azure Front Door, Azure Application Gateway, or a third-party service, to provide OWASP-based protection.
    - Employ the appropriate use of access restrictions so that the app service is only reachable from valid locations. For example, if the app service is hosting APIs, and is fronted by APIM, setup an access restriction so that the app service is only accessible from APIM.
- For VNET integration. Since subnet size can't be changed after assignment, use a subnet that's large enough to accommodate whatever scale your app might reach. To avoid any issues with subnet capacity, you should use a /26 with 64 addresses.
- Use the [built-in tools](https://azure.github.io/AppService/2021/04/13/Network-&-Connectivity-Troubleshooting-Tool.html) for troubleshooting any networking issues.
- Avoid SNAT port exhaustion by following the [guidance](https://docs.microsoft.com/en-us/azure/app-service/troubleshoot-intermittent-outbound-connection-errors). 
- Review and follow the recommendations outlined in the [Network Security section](https://docs.microsoft.com/en-us/security/benchmark/azure/baselines/app-service-security-baseline?toc=/azure/app-service/toc.json#network-security) of the Azure security baseline for App Service.
### ASE:
- Connecting from an App Service:
    - Where private connectivity to other Azure services is required, use Private Link if supported by those services.  Please refer to the [list of services that support Private Link](https://docs.microsoft.com/en-us/azure/private-link/availability).
    - If you need a dedicated outbound address, consider the use of a [NAT Gateway](https://docs.microsoft.com/en-us/azure/azure-functions/functions-how-to-use-nat-gateway).
- Connecting to an App Service:
    - Ensure you have a Web Application Firewall (WAF) implemented in front of your App Service, using Azure Front Door, Azure Application Gateway, or a third-party service, to provide OWASP-based protection.
    - Employ the appropriate use of access restrictions so that the app service is only reachable from valid locations. For example, if the app service is hosting APIs, and is fronted by APIM, setup an access restriction so that the app service is only accessible from APIM.
- Use the [built-in tools](https://azure.github.io/AppService/2021/04/13/Network-&-Connectivity-Troubleshooting-Tool.html) for troubleshooting any networking issues.
- Avoid SNAT port exhaustion by following the [guidance](https://docs.microsoft.com/en-us/azure/app-service/troubleshoot-intermittent-outbound-connection-errors). 
- Review and follow the recommendations outlined in the [Network Security section](https://docs.microsoft.com/en-us/security/benchmark/azure/baselines/app-service-security-baseline?toc=/azure/app-service/toc.json#network-security) of the Azure security baseline for App Service.
- It is recommended that your subnet be sized with a /24 CIDR range, providing 256 addresses.
