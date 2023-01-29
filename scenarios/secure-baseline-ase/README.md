# Line of Business application using internal App Service Environment v3

This reference architecture shows how to run a web-app workload for line of business applications on Azure App Services Environment (ASE) in a secure configuration. 

## Architectural Diagram:

![image](/docs/Images/ASE/AppServiceLandingZoneArchitecture.png)
*Download a [Visio](/docs/AppServiceLandingZoneArchitecture.vsd) file that contains this architecture diagram.*


## Deployed Resources:
![image](/docs/Images/ASE/AppServiceDeployedResources.png)

Deployment Details:
| Deployment Methodology | GitHub Actions | Status
|--------------|--------------|-----------|
|[Bicep](/scenarios/secure-baseline-ase/bicep/README.md)|[LOB-ILB-ASEv3-Bicep.yml](/.github/workflows/LOB-ILB-ASEv3-Bicep.yml) | [![Single-tenant ASEv3 Secure Baseline: Bicep Deploy](https://github.com/Azure/appservice-landing-zone-accelerator/actions/workflows/bicep.secure-baseline.ase.yml/badge.svg)](https://github.com/Azure/appservice-landing-zone-accelerator/actions/workflows/bicep.secure-baseline.ase.yml)
|[Terraform](/scenarios/secure-baseline-ase/terraform/README.md)|Coming Soon| [![Terraform Deploy](https://github.com/Azure/appservice-landing-zone-accelerator/actions/workflows/terraform.secure-baseline.ase.yml/badge.svg)](https://github.com/Azure/appservice-landing-zone-accelerator/actions/workflows/terraform.secure-baseline.ase.yml)
|[ARM](/scenarios/secure-baseline-ase/azure-resource-manager/README.md)| Not provided* |

## Cost estimation:

The current default will cost approx. $40-$50 per day depending on the selected region (without any workload or Redis Enterprise). If deploying the current defult plus Redis Enterprise it will cost approx. $72-$82 per day. It is deploying an ASE V3 that is zone-redundant and one Isolated V2 SKU Windows App Service Plan scaled to 3 instances (default with zone redundancy). For more accurate prices please check [pricing models for ASE V3](https://docs.microsoft.com/en-us/azure/app-service/environment/overview#pricing) and [pricing for Azure Cache for Redis](https://azure.microsoft.com/en-us/pricing/details/cache/).

---

## Other Considerations

1. The redis.bicep contains an optional parameter to select the enterprise tier that best apply for your scenario.
