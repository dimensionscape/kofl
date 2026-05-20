param(
	[string]$UpstreamRoot
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$defaultUpstreamRoot = Join-Path (Split-Path -Parent $root) "openfl\src\openfl"
$sourceRoot = if ($UpstreamRoot) { $UpstreamRoot } else { $defaultUpstreamRoot }
$destRoot = Join-Path $root "Sources\openfl"

if (-not (Test-Path $sourceRoot)) {
	throw "Cannot find upstream OpenFL source at '$sourceRoot'"
}

Get-ChildItem $sourceRoot -Recurse -File | ForEach-Object {
	$relativePath = $_.FullName.Substring($sourceRoot.Length).TrimStart('\', '/')
	$destPath = Join-Path $destRoot $relativePath
	$destDir = Split-Path -Parent $destPath

	if (-not (Test-Path $destDir)) {
		New-Item -ItemType Directory -Force -Path $destDir | Out-Null
	}

	if (-not (Test-Path $destPath)) {
		Copy-Item $_.FullName $destPath
	}
}
