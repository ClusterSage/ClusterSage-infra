# ClusterSage Infra

This folder is prepared to become the standalone `ClusterSage-infra` repository.

## Contents

- `terraform/modules`: reusable Azure and platform bootstrap modules.
- `terraform/envs/global-shared`: globally shared resources, especially ACR.
- `terraform/envs/nonprod-shared`: shared dev/staging Front Door, WAF, and optional shared non-prod AI services.
- `terraform/envs/dev`: dev runtime resources.
- `terraform/envs/staging`: staging runtime resources.
- `terraform/envs/prod`: prod runtime resources and prod Front Door.

Terraform provisions Azure infrastructure and platform bootstrap components only. Application workloads are deployed by ArgoCD from `repos/ClusterSage-gitops`.

Current live Azure deployments are managed from `global-shared`, `nonprod-shared`, `dev`, `prod`, and `identities`. The `staging` root remains defined in Terraform but is not currently deployed in Azure.

The old production Docker Compose deployment path was retired in favor of AKS, Helm, and GitOps.

Current env roots can now express, per environment:

- autoscaled AKS system-pool sizing
- an optional separate AKS user node pool
- an optional cross-region PostgreSQL flexible-server read replica for disaster recovery
- a private AKS control plane with API server VNet integration when the live cluster has already been cut over safely

These remain normal Terraform-managed infrastructure changes and still require reviewed plans and explicit approval before apply, especially for production.

## Safe apply/destroy

For environments that create AKS and then bootstrap in-cluster components such as Argo CD and kgateway, use the wrapper scripts instead of a single raw Terraform command from an empty or fully-populated state:

- Safe apply: `terraform/scripts/apply-env-safe.ps1 -Environment prod`
- Safe destroy: `terraform/scripts/destroy-env-safe.ps1 -Environment prod`

These scripts use a two-phase flow:

1. Create or destroy the in-cluster bootstrap layer separately.
2. Create or destroy the Azure infrastructure layer.

This avoids Terraform provider lifecycle issues that can occur when the same root both creates an AKS cluster and immediately uses Kubernetes and Helm providers against that cluster in the same one-shot operation.

## Production AKS access posture

`terraform/envs/prod` now matches the live production cluster with:

- a private AKS API server
- API server VNet integration on a dedicated `snet-apiserver` subnet
- a user-assigned control-plane identity with subnet-scoped network role assignments
- an Australia Central access bridge in `jump-rg` with a peered VNet, Bastion developer host, and jump VM for private-cluster access when Central India quota is constrained

ArgoCD and application delivery continue to work because reconciliation happens from inside the cluster. The prod root keeps the bootstrap toggles disabled by default for steady-state operations, and the AKS resource intentionally ignores the cutover-only control-plane attributes that were finalized through Azure API operations to avoid replacement-driven drift.

## GitHub Actions scope

Terraform PR validation and Terraform apply are intentionally disabled for `terraform/envs/staging` until a staging environment is deployed again. Workflow auto-detection now targets `identities`, `global-shared`, `nonprod-shared`, `dev`, and `prod`.
