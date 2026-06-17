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
  terraform apply -auto-approve -var bootstrap_kgateway=false -var bootstrap_argocd=false
  terraform apply -auto-approve -var bootstrap_kgateway=true -var bootstrap_argocd=true
}
finally {
  Pop-Location
}
