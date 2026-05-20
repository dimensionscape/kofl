$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testDir = Join-Path $root "tests\\openfl\\eventdispatcher"

Push-Location $testDir
try {
	haxe test.hxml
}
finally {
	Pop-Location
}

