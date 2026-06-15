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

The old production Docker Compose deployment path was retired in favor of AKS, Helm, and GitOps.
