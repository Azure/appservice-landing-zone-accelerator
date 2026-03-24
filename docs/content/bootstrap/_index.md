---
title: "Bootstrap CI/CD"
weight: 20
geekdocCollapseSection: true
---

The bootstrap creates everything for secure CI/CD with **OIDC** — managed identities, state storage, pipelines, and environments. No secrets stored in your repos.

## What gets created

| Resource | Description |
|----------|-------------|
| **6 Managed Identities** | Separate plan/apply identities per environment (dev, test, prod) |
| **OIDC Federation** | Workload Identity Federation linking your CI/CD platform to Azure |
| **State Storage** | Azure Storage Account with per-environment containers |
| **Environments** | CI/CD environments with approval gates and deployment locks |
| **Pipelines** | CI/CD workflows for plan, apply, and PR validation |

## Choose your platform

| | GitHub Actions | Azure DevOps |
|---|---|---|
| **Guide** | [GitHub Actions →]({{< relref "bootstrap/github-actions" >}}) | [Azure DevOps →]({{< relref "bootstrap/azure-devops" >}}) |
| **Source Repo** | [github-terraform-oidc-ci-cd](https://github.com/Azure-Samples/github-terraform-oidc-ci-cd) | [azure-devops-terraform-oidc-ci-cd](https://github.com/Azure-Samples/azure-devops-terraform-oidc-ci-cd) |

## Pointing the pipeline at this repo

The bootstrap repos create a new repository with CI/CD workflows. Set the `example_repo` input to point the pipeline at the infrastructure code in **this** repo (or your fork):

- **Terraform:** set `example_repo` to point at `infra/terraform/`
- **Bicep:** set `example_repo` to point at `infra/bicep/`

The generated workflows will run `terraform plan`/`apply` or `az deployment sub create` against the code in that path.

## Backend configuration

The empty `backend "azurerm" {}` block in `infra/terraform/terraform.tf` is intentional — **do not hardcode backend settings in it**. The bootstrap-generated pipeline injects the backend config (storage account, container, key) at runtime via `-backend-config` CLI args. This keeps the Terraform code environment-agnostic. See the [example-module](https://github.com/Azure-Samples/github-terraform-oidc-ci-cd/tree/main/example-module) in the bootstrap repo for the reference pattern.

## Prerequisites

- [Terraform CLI](https://www.terraform.io/downloads) and [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed locally
- An [Azure subscription](https://azure.microsoft.com/pricing/purchase-options/azure-account) with **Owner** or **User Access Administrator** role
