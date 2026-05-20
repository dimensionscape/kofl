$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$khaRoot = Join-Path $root "Kha"
$embeddedHaxe = Join-Path $khaRoot "Tools\\windows_x64"
$targetDir = Join-Path $root "build\\windows"

$haxePath = if (Test-Path (Join-Path $embeddedHaxe "haxe.exe")) { $embeddedHaxe } else { Split-Path (Get-Command haxe).Path }

node (Join-Path $khaRoot "make.js") `
	--from $root `
	--to $targetDir `
	--target windows `
	--visualstudio vs2022 `
	--kha $khaRoot `
	--haxe $haxePath `
	--compile

