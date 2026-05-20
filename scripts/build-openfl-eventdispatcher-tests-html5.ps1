$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$khaRoot = Join-Path $root "Kha"
$embeddedHaxe = Join-Path $khaRoot "Tools\\windows_x64"
$testRoot = Join-Path $root "tests\\openfl\\eventdispatcher"
$targetDir = Join-Path $root "build\\tests\\openfl-eventdispatcher-html5"

$haxePath = if (Test-Path (Join-Path $embeddedHaxe "haxe.exe")) { $embeddedHaxe } else { Split-Path (Get-Command haxe).Path }

node (Join-Path $khaRoot "make.js") `
	--from $testRoot `
	--to $targetDir `
	--target html5 `
	--main Tests `
	--kha $khaRoot `
	--haxe $haxePath `
	--compile
