# Business Continuity and Disaster Recovery
## Design Considerations
- Consider Recovery Point Objective (RPO) and Recovery Time Objective(RTO) requirements, as those will dictate if App Gateway needs to be deployed in:
    - Single or Multi Region
    - Active-Active or Active-Standby Configuration
- Do we need a single point of entry or multiple entry points based on from where the requests are coming? This will facilitate decision for Traffic Manager or Front Door
    - Is cost a concern?
    - Is latency or an extra hop a concern?
    - Any third-party solution used to direct traffic to App Gateway? 
- Backup of App Gateway configuration – Only ARM Template? Where is it stored and how it’ll be utilized – Manually or through automation e.g., ADO pipelines?
### Multi-Tenanted:
- If your application needs to be redundant across regions, deploy the solution in more than one region and use Traffic Manager or Azure Front Door to balance load between these deployments.
- If users of your application span geographies, consider deploying to single regions in each applicable geography and use Traffic Manager or Azure Front Door to provide geography-based routing.  This will provide enhanced performance and increased redundancy.
- If you need to recover from a disaster, consider if redeploying the application from a CI/CD process would be adequate.  Also consider that a web app is a component in a larger solution, and you will need to consider the DR processes for the other components in the solution.
### App Service Environment:
- Guidance on architecting an ASE-based solution for [high availability within a region](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/enterprise-integration/ase-high-availability-deployment).
- Guidance on [geographic redundancy](https://docs.microsoft.com/en-us/azure/app-service/environment/app-service-app-service-environment-geo-distributed-scale).

## Design Recommendations
### Multi-Tenanted:
- Deploy your App Service solution to at least 2 regions, and possibly to multiple geographies, if required.
- Utilize Azure Front Door to provide load balancing and WAF capabilities between the different deployments.
- Modify your CI/CD processes so that changes to the solution are deployed to each target region.
- Ensure that your CI/CD processes are setup to re-deploy the solution in case a disaster impacts one or more of the deployments.
### App Service Environment:
- Deploy one instance of the ASE in 2 separate Availability Zones in the same region, or in 2 different regions if cross-regional HA is required.
- Where your ASE instances are deployed across Availability Zones in the same region, use Azure Application Gateway to provide load balancing and WAF capabilities between the instances.
- Where cross-regional HA is required, utilize Azure Front Door to provide load balancing and WAF capabilities between the different instances.
- Modify your CI/CD processes so that changes to the solution are deployed to each target ASE instance.
