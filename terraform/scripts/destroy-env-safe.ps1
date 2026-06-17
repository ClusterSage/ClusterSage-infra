param(
  [Parameter(Mandatory = $true)]
  [string]$Environment
)

$ErrorActionPreference = "Stop"

$envPath = Join-Path $PSScriptRoot "..\envs\$Environment"
$envPath = [System.IO.Path]::GetFullPath($envPath)

if (-not (Test-Path $envPath)) {
  throw "Environment path not found: $envPath"
}

Push-Location $envPath
try {
  terraform destroy -auto-approve -target=module.kgateway_bootstrap -target=module.argocd_bootstrap
  terraform destroy -auto-approve -var bootstrap_kgateway=false -var bootstrap_argocd=false
}
finally {
  Pop-Location
}
