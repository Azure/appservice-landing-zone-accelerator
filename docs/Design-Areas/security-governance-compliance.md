# Security, Governance and Compliance
## Design Considerations
- Consider what level of logging is necessary to meet your organization’s compliance requirements. 
- Review your security requirements to determine if they allow your web applications to be run on shared network infrastructure or if they require the complete network/virtual machine isolation available with [App Service Environments](https://docs.microsoft.com/en-us/azure/app-service/environment/overview). 
- Review which Web Application Firewall [rulesets](https://docs.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules?tabs=owasp32) and/or custom rules are necessary to meet your security and compliance requirements.
- Evaluate the security of your software supply chain and determine the tools and processes in place to automatically patch application dependency vulnerabilities and reliably deploy them into your environment.
## Design Recommendations
- Use [Private Endpoint](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview) to privately access [Azure services](https://docs.microsoft.com/en-us/azure/private-link/availability) through your vNet 
- Use [Azure Policy](https://docs.microsoft.com/en-us/azure/app-service/policy-reference) to assess and enforce Regulatory Compliance controls
- Apps should only be accessible over HTTPS.
- Use the latest TLS version when encrypting information in transit.
- Review the list of SSL cyphers.
- Store application secrets (database credentials, API tokens, private keys) in Azure Key Vault and configure your App Service app to access them securely with a Managed Identity.
- [Enable Cross-Origin Resource Sharing (CORS)](https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-rest-api#enable-cors) within App Services or using your own CORS utilities to indicate which origins the user’s browser should permit resources to be loaded from.
- When deploying containerized web applications to App Services, [enable Azure Defender for container registries](https://docs.microsoft.com/en-us/azure/security-center/defender-for-container-registries-introduction) to automatically scan images for vulnerabilities.
- Enable[ Azure Defender for App Service](https://docs.microsoft.com/en-us/azure/security-center/defender-for-app-service-introduction#:~:text=%20When%20you%20enable%20Azure%20Defender%20for%20App,App%20Service%20resources%20by%20monitoring%3A%0Athe%20VM...%20More%20) to assess the security of your web applications and detect threats to your App Service resources.

