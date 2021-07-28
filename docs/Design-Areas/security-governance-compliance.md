# Security, Governance and Compliance
## Design Considerations
- Consider what level of logging is necessary to meet your organization’s compliance requirements. 
- Review your security requirements to determine if they allow your web applications to be run on shared network infrastructure or if they require the complete network/virtual machine isolation available with App Service Environments. 
- Review which Web Application Firewall rulesets and/or custom rules are necessary to meet your security and compliance requirements.
- Evaluate the security of your software supply chain and determine the tools and processes in place to automatically patch application dependency vulnerabilities and reliably deploy them into your environment.
## Design Recommendations
- Use Azure built-in roles to provide least privilege permissions to manage App Service Plans and Websites
- Managed Identity should be used with your web, API, and Function apps when accessing other Azure AD-protected resources.
- Enable Cross-Origin Resource Sharing (CORS) within App Services or using your own CORS utilities to indicate which origins the user’s browser should permit resources to be loaded from.
- When possible, disable anonymous access and use the built-in App Services authentication and authorization capabilities to sign-in users
- Use private endpoints to privately access Azure services such as Azure Key Vault, Azure Storage, and Azure SQL Database through your vNet 	
- Use Azure Policy to assess and enforce Regulatory Compliance controls
- Apps should only be accessible over HTTPS.
- Use the latest TLS version when encrypting information in transit.
- Store application secrets (database credentials, API tokens, private keys) in Azure Key Vault and configure your App Service app to access them securely with a Managed Identity.
- When deploying containerized web applications to App Services, enable Azure Defender for container registries to automatically scan images for vulnerabilities.
- Enable Azure Defender for App Service to assess the security of your web applications and detect threats to your App Service resources.
