# Identity and Access Management
## Design Considerations
- Decide on the level of exposure for your App Service: public, private, or both.
- Decide on how to authenticate users that need to access your App Service: anonymous, internal corporate users, social accounts, other identity provider, or a mixture of these.
- Decide on whether to use system-assigned or user-assigned managed identities for your App Service when connecting to AAD-protected backend resources.
- Consider creating custom roles following the principle of least privilege when out-of-box roles require modifications on existing permissions.
## Design Recommendations
- If the App Service requires authentication:
    - If access to the entire app service needs to be restricted to authenticated users, disable anonymous access.
    - Use the Easy Auth capabilities of App Services, instead of writing your own authentication and authorization code.
    - Use separate app service registrations for separate slots or environments.
    - If the App Service is intended for internal users only, use client certificate authentication for increased security.
    - If the App Service is intended for external users, utilize Azure AD B2C to authenticate to social accounts and Azure AD accounts. 
- Utilize system-assigned managed identities to securely access AAD-protected backend resources.
- Ensure that users with access to Production resources in Azure are controlled and limited.
- For automated deployment purposes, setup a service principal that has the minimum required permissions to deploy from the pipeline
- Utilize [Cross-origin resource sharing (CORS)](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) to limit the domains that are allowed to access your 
App Service.
- Review and follow the recommendations outlined in the [Identity and Access Control section](https://docs.microsoft.com/en-us/security/benchmark/azure/baselines/app-service-security-baseline?toc=/azure/app-service/toc.json#identity-and-access-control) of the Azure security baseline for App Service.
