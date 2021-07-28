# Management and Monitoring
## Design Consideration
- Considerations for either Multi-tenanted(MT) or App Service Environment(ASE) Be aware of [App Service limits](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#app-service-limits). Scale up or use multiple App Service instances to scale beyond those limits. Automate the scale-out and scale-in with auto-scaling rules.
- Configure centralized log management solution and integrate your app services to send logs there.
- Enable Always On or, for .NET applications on Windows, leverage [IIS Application Initialization](https://docs.microsoft.com/en-us/iis/get-started/whats-new-in-iis-8/iis-80-application-initialization).
- Enable IIS Logs (AppService HTTPLogs) either in a storage account or Log Analytics 
- Availability Tests help to determine when your app service is not reachable. Implement health checks for your endpoints and use them for health probes, dependency checks and availability tests.
- From [WellArchitected-Assessment](https://github.com/Azure/WellArchitected-Assessment/blob/main/assessments/operationalexcellence/service.md#Azure-App-Service):
    - For App Service Environments, consider configuring [Upgrade Preference](https://docs.microsoft.com/azure/app-service/environment/using-an-ase#upgrade-preference) if multiple environments are used. 
    - Use deployment slots for resilient code deployments and to avoid unnecessary Worker restarts (some triggers include content deployment, app setting changes, VNet integration configuration changes, etc.)
    - Use [run from package](https://docs.microsoft.com/azure/app-service/deploy-run-package) to avoid deployment conflicts.
•	Consider using Linux as operating system for more effective cost management.
## Design Recommendation 
- Use Application Insights or another Application Performance Management solution to monitor & learn how your application behaves in different environments.
    - For different environments collect telemetry data into different Application Insights instances.
    - If your application has multiple components separated into different services but you would like to examine their behavior together, then collect their telemetry data into same Application Insights instance but label them with different cloud role names.
    - Export Application Insights data to an Azure Log Analytics Workspace. Prefer a single Workspace for the organization.
- For stateless app services, disable ARR Affinity
- For a high-level overview of your app service’s performance, use Azure Monitor Dashboards
- Use AutoHeal (proactive or custom) to gather helpful data for a perf/stability issue.
- Alerts are a proactive way for you to identify and begin troubleshooting problems before you hear from the user.  
