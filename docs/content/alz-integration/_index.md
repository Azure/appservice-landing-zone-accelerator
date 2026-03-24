---
title: "ALZ Integration"
weight: 40
geekdocCollapseSection: true
---

{{< hint type=important >}}
**ALZ integration is not optional.** This accelerator is designed for deployment into an Azure Landing Zone. It deploys a spoke workload that expects hub VNet peering, centralized firewall egress, and DINE policy-driven diagnostics from the platform. Deploy your Platform Landing Zone first using the [ALZ IaC Accelerator](https://aka.ms/alz/acc).
{{< /hint >}}

This accelerator deploys a **spoke** only. Hub networking (Azure Firewall, Bastion, hub VNet, peering) must be provisioned first using the [Azure Landing Zone IaC Accelerator](https://aka.ms/alz/acc). The spoke VNet peers to the hub, all egress routes through Azure Firewall, and Azure Policy (DINE) handles diagnostic settings — these are platform-level concerns provided by the ALZ.

## Connect your spoke to a hub

After deploying your Platform Landing Zone, set these parameters to peer the spoke and route traffic through the hub firewall.

### Terraform

```hcl
hub_virtual_network_id         = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<hub-vnet>"
hub_firewall_private_ip        = "10.0.0.4"
hub_route_table_address_spaces = ["10.0.0.0/16"]
```

### Bicep

```bicep
param hubVnetResourceId = '/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<hub-vnet>'
param firewallInternalIp = '10.0.0.4'
```

These values come from the ALZ IaC Accelerator deployment outputs. The spoke VNet is peered to the hub and a UDR routes all outbound traffic through Azure Firewall.
