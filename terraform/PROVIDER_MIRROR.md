# Terraform Provider Mirror

Use this when a corporate network blocks Terraform provider ZIP downloads from `releases.hashicorp.com`.

Do not commit `.terraform/` or provider binaries to Git.

## On An Unblocked Machine

From `repos/ClusterSage-infra/terraform`:

```powershell
.\scripts\build-provider-mirror.ps1
```

This creates:

```text
repos/ClusterSage-infra/terraform/.terraform-provider-mirror/
```

Copy that folder to the same path on the blocked machine.

## On The Blocked Machine

From `repos/ClusterSage-infra/terraform`:

```powershell
.\scripts\use-provider-mirror.ps1
$env:TF_CLI_CONFIG_FILE = "$(Resolve-Path .\.terraformrc.local)"
terraform init
terraform validate
```

The local CLI config tells Terraform to install HashiCorp providers from the copied mirror folder instead of downloading them directly.

Run `terraform init` and `terraform validate` from the specific env root, such as `envs/dev`. Do not use Terraform workspaces for environment selection.

