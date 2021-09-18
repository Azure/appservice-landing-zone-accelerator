# Application Automation and DevOps
## Design Considerations
- When securing and protecting access to development, test, Q&A, and production environments, consider security options from a CI/CD perspective. Deployments happen automatically, so map access control accordingly.
- Consider using prefixes and suffixes with well-defined conventions to uniquely identify every deployed resource. These naming conventions avoid conflicts when deploying solutions next to each other and improve overall team agility and throughput.
- Consider deploying other resources like subscriptions, tagging, and labels to support your DevOps experience by tracking and tracing deployments and related artifacts.
- Depending on the network configuration, App Services might not be reachable from the public internet and the use of public hosted agents will not work for deployments. Plan to use [self-hosted agents](https://azure.github.io/AppService/2021/01/04/deploying-to-network-secured-sites.html) in that scenario.
- Consider deploying containerized applications to take advantage of simplified deployments using Docker Hub or Azure Container Registry.
- Adopt a branching strategy which will help you collaborate while providing flexibility as well. Keep your strategy simple, use short-living feature isolation and allow modifications back to your main branch through pull requests with manual and automated code analysis.
- Make sure that your business logic is checked by unit tests in the build pipeline. Use integration tests in the release pipeline to check that every service and resource work together after a new release and check the most critical UI elements with automated UI tests. Cover non-functional performance requirements with load tests (eg k6, JMeter) in your staging environment.

## Design Recommendations
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
