param(
  [string]$MirrorPath = ".terraform-provider-mirror"
)

$ErrorActionPreference = "Stop"

$TerraformDir = Resolve-Path (Join-Path $PSScriptRoot "..")
$MirrorFullPath = Resolve-Path (Join-Path $TerraformDir $MirrorPath)
$ConfigPath = Join-Path $TerraformDir ".terraformrc.local"
$MirrorForTerraform = $MirrorFullPath.Path -replace "\\", "/"
$IncludedProviders = @(
  "registry.terraform.io/hashicorp/azuread",
  "registry.terraform.io/hashicorp/azurerm",
  "registry.terraform.io/hashicorp/helm",
  "registry.terraform.io/hashicorp/http",
  "registry.terraform.io/hashicorp/kubernetes",
  "registry.terraform.io/hashicorp/random",
  "registry.terraform.io/hashicorp/time"
)
$IncludeList = ($IncludedProviders | ForEach-Object { """$_""" }) -join ", "

@"
provider_installation {
  filesystem_mirror {
    path    = "$MirrorForTerraform"
    include = [$IncludeList]
  }

  direct {
    exclude = [$IncludeList]
  }
}
"@ | Set-Content -LiteralPath $ConfigPath -NoNewline

Write-Host "Terraform CLI config written to: $ConfigPath"
Write-Host "Run this before terraform init in the same PowerShell session:"
Write-Host "`$env:TF_CLI_CONFIG_FILE = '$ConfigPath'"
