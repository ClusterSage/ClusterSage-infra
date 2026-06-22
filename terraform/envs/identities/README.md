# ClusterSage identities env

This Terraform root creates the shared Microsoft Entra application registration and service principal used by GitHub Actions OIDC across the ClusterSage repositories.

## Current configuration model

This root no longer relies on a committed `terraform.tfvars`.

The non-secret defaults now live in [variables.tf](./variables.tf), including:

- `subscription_id`
- `tenant_id`
- `entra_owner_object_id`
- `acr_name`
- `acr_resource_group_name`
- `acr_abac_enabled`
- `github_federated_credentials`

Update `variables.tf` if those non-secret defaults need to change.

You can fetch the first two values with:

```powershell
az account show --query id --output tsv
az account show --query tenantId --output tsv
```

Adjust `github_federated_credentials` if:

- your GitHub default branch is not `main`
- you want additional repos trusted
- your org or repo names differ from the current `ClusterSage/ClusterSage-*` convention

Keep `entra_owner_object_id` pinned to the live user object ID that owns the shared app registration. Using the current authenticated principal in CI would cause Terraform drift by trying to replace that owner with the GitHub Actions service principal.

## Expected backend

This root uses the shared Azure Blob backend:

- resource group: `terraform-rg`
- storage account: `norahterraformstorageacc`
- container: `terraformstate`
- state key: `identities.tfstate`

## Validate locally

```powershell
cd repos/ClusterSage-infra/terraform/envs/identities
terraform init
terraform validate
terraform plan
```

`terraform plan` will only succeed after:

- you are authenticated to the correct Azure tenant/subscription
- the referenced global shared ACR already exists

## Useful outputs

After `apply`, use these outputs in GitHub repository variables:

- `github_actions_client_id` -> `AZURE_CLIENT_ID`
- `azure_tenant_id` -> `AZURE_TENANT_ID`
- `azure_subscription_id` -> `AZURE_SUBSCRIPTION_ID`
- `acr_name` -> `ACR_NAME`
- `acr_login_server` -> `ACR_LOGIN_SERVER`
