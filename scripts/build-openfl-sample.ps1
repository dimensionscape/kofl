param(
	[Parameter(Mandatory = $true)][string]$SampleRoot,
	[Parameter(Mandatory = $true)][string]$MainClass,
	[Parameter(Mandatory = $true)][string]$OutputName,
	[string]$Target = "html5"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$khaRoot = Join-Path $root "Kha"
$embeddedHaxe = Join-Path $khaRoot "Tools\\windows_x64"
$targetDir = Join-Path $root ("build\\samples\\" + $OutputName + "-" + $Target)

$haxePath = if (Test-Path (Join-Path $embeddedHaxe "haxe.exe")) { $embeddedHaxe } else { Split-Path (Get-Command haxe).Path }

$makeArgs = @(
	(Join-Path $khaRoot "make.js"),
	"--from", (Join-Path $root $SampleRoot),
	"--to", $targetDir,
	"--target", $Target,
	"--main", $MainClass,
	"--kha", $khaRoot,
	"--haxe", $haxePath
)

if ($Target -eq "windows") {
	$makeArgs += @("--visualstudio", "vs2022")
}

$makeArgs += "--compile"

node @makeArgs
