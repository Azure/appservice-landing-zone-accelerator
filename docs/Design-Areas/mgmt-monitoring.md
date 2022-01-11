# Management and Monitoring
## Design Consideration
- Be aware of [App Service limits](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#app-service-limits). Scale up or use multiple App Service instances to scale beyond those limits. Performance testing should be completed prior to gain a proper understanding of sizing and instance count for the [App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans).
- Consider if scaling out/up of the App Service Plan is beneficial for your scenario.  If so, [automate the scale-out and scale-in](https://docs.microsoft.com/en-us/azure/azure-monitor/autoscale/autoscale-best-practices#manual-scaling-is-reset-by-autoscale-min-and-max) with auto-scaling rules. 
- Leverage [Availability Tests](https://docs.microsoft.com/en-us/azure/azure-monitor/app/availability-overview) and set alerts on them to help determine when your app service is not reachable. 
- Alerts are a proactive way for you to identify and begin troubleshooting problems before you hear from the user, but can also contribute noise to the environment. Therefore, test your scenario to find an acceptable level of alerting.  Also, be aware of the [limitation on alert rules](https://docs.microsoft.com/en-us/azure/azure-monitor/service-limits).
- For App Service Environments, consider configuring [Upgrade Preference](https://docs.microsoft.com/azure/app-service/environment/using-an-ase#upgrade-preference) if multiple environments are used. 
## Design Recommendation 
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
 
