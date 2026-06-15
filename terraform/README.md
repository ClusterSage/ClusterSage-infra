# ClusterSage Terraform

Terraform provisions Azure infrastructure and platform bootstrap components only. Application workloads are deployed through ArgoCD/GitOps.

## Roots

- `envs/global-shared`: global shared ACR and global/common resources.
- `envs/nonprod-shared`: non-prod shared Front Door, WAF, optional shared non-prod AI services.
- `envs/dev`: dev runtime resources and platform bootstrap.
- `envs/staging`: staging runtime resources and platform bootstrap.
- `envs/prod`: prod runtime resources, platform bootstrap, prod Front Door, and prod WAF.

Each root uses a separate Azure Blob Storage backend key. Terraform workspaces are not used for environment separation.

## Apply Order

1. `global-shared`
2. `nonprod-shared` initial apply with origin attachment disabled
3. `dev`
4. `staging`
5. `nonprod-shared` second apply with dev/staging origin attachment enabled
6. `prod`

For production-first provisioning, apply `global-shared` and then `prod`.
