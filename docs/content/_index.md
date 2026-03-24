---
title: "App Service Landing Zone Accelerator"
weight: 1
---

Production-ready **Terraform** and **Bicep** for deploying Azure App Service in a secure, spoke-level landing zone. Built on [Azure Verified Modules (AVM)](https://aka.ms/avm), aligned with the [Cloud Adoption Framework](https://learn.microsoft.com/azure/cloud-adoption-framework/).

{{< hint type=important >}}
**Prerequisite: Platform Landing Zone required.** These examples are designed for deployment into an [Azure Landing Zone](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/). You must have a Platform Landing Zone deployed first — including hub networking, Azure Firewall, and centralized logging. Deploy one using the [ALZ IaC Accelerator](https://aka.ms/alz/acc).
{{< /hint >}}

You get: App Service (multi-tenant or ASE v3) with VNet integration, Azure Front Door with WAF, Key Vault, private endpoints for all services, managed identities, Log Analytics, and Application Insights. Optional add-ons: Azure SQL, Redis Cache, App Configuration, jump host VM. Hub networking is provisioned separately via the [ALZ IaC Accelerator](https://aka.ms/alz/acc).

**→ [Get started]({{< relref "getting-started" >}})**
