param(
	[Parameter(Mandatory = $true)][string]$Suite,
	[string]$Target = "html5"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$khaRoot = Join-Path $root "Kha"
$embeddedHaxe = Join-Path $khaRoot "Tools\\windows_x64"
$testRoot = Join-Path $root ("tests\\openfl\\" + $Suite)
$targetDir = Join-Path $root ("build\\tests\\openfl-" + $Suite + "-" + $Target)

if (-not (Test-Path $testRoot)) {
	throw "Cannot find KOFL OpenFL test suite '$Suite' at '$testRoot'"
}

$mainClass = if (Test-Path (Join-Path $testRoot "Tests.hx")) {
	"Tests"
} elseif (Test-Path (Join-Path $testRoot "src\\Main.hx")) {
	"Main"
} else {
	throw "Suite '$Suite' has no Tests.hx or src/Main.hx entrypoint"
}

$haxePath = if (Test-Path (Join-Path $embeddedHaxe "haxe.exe")) { $embeddedHaxe } else { Split-Path (Get-Command haxe).Path }

$makeArgs = @(
	(Join-Path $khaRoot "make.js"),
	"--from", $testRoot,
	"--to", $targetDir,
	"--target", $Target,
	"--main", $mainClass,
	"--kha", $khaRoot,
	"--haxe", $haxePath
)

if ($Target -eq "windows") {
	$makeArgs += @("--visualstudio", "vs2022")
}

$makeArgs += "--compile"

$nativePrefExists = $null -ne (Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue)
if ($nativePrefExists) {
	$previousNativePref = $PSNativeCommandUseErrorActionPreference
	$PSNativeCommandUseErrorActionPreference = $false
}

try {
	node @makeArgs
} finally {
	if ($nativePrefExists) {
		$PSNativeCommandUseErrorActionPreference = $previousNativePref
	}
}

if ($LASTEXITCODE -ne 0) {
	throw "Kha build failed for OpenFL suite '$Suite' on target '$Target'"
}
