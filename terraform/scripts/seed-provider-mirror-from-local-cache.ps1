param(
  [string]$MirrorPath = ".terraform-provider-mirror",
  [string]$LegacyProviderRoot = "..\..\..\terraform\.terraform\providers\registry.terraform.io\hashicorp",
  [switch]$EnableWindows386Compatibility = $true
)

$ErrorActionPreference = "Stop"

$TerraformDir = Resolve-Path (Join-Path $PSScriptRoot "..")
$LegacyRoot = Resolve-Path (Join-Path $TerraformDir $LegacyProviderRoot)
$MirrorRoot = Join-Path $TerraformDir $MirrorPath

$providers = @(
  @{ Name = "azuread"; Version = "3.8.0"; SourcePlatform = "windows_386"; TargetPlatform = "windows_amd64" },
  @{ Name = "azurerm"; Version = "4.71.0"; SourcePlatform = "windows_amd64"; TargetPlatform = "windows_amd64" },
  @{ Name = "helm"; Version = "2.17.0"; SourcePlatform = "windows_386"; TargetPlatform = "windows_amd64" },
  @{ Name = "http"; Version = "3.6.0"; SourcePlatform = "windows_386"; TargetPlatform = "windows_amd64" },
  @{ Name = "kubernetes"; Version = "2.38.0"; SourcePlatform = "windows_386"; TargetPlatform = "windows_amd64" },
  @{ Name = "random"; Version = "3.9.0"; SourcePlatform = "windows_386"; TargetPlatform = "windows_amd64" },
  @{ Name = "time"; Version = "0.14.0"; SourcePlatform = "windows_386"; TargetPlatform = "windows_amd64" }
)

New-Item -ItemType Directory -Force -Path $MirrorRoot | Out-Null

foreach ($provider in $providers) {
  $sourcePlatform = $provider.SourcePlatform
  if ($sourcePlatform -eq "windows_386" -and -not $EnableWindows386Compatibility) {
    continue
  }

  $sourcePath = Join-Path $LegacyRoot "$($provider.Name)\$($provider.Version)\$sourcePlatform"
  if (-not (Test-Path $sourcePath)) {
    throw "Provider cache not found: $sourcePath"
  }

  $targetPath = Join-Path $MirrorRoot "registry.terraform.io\hashicorp\$($provider.Name)\$($provider.Version)\$($provider.TargetPlatform)"
  New-Item -ItemType Directory -Force -Path $targetPath | Out-Null
  Copy-Item -Path (Join-Path $sourcePath "*") -Destination $targetPath -Recurse -Force
}

Write-Host "Provider mirror seeded from local cache at: $MirrorRoot"
if ($EnableWindows386Compatibility) {
  Write-Host "windows_386-only providers were copied into windows_amd64 mirror paths for local compatibility."
}
