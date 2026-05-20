$ErrorActionPreference = "Stop"

$runner = Join-Path $PSScriptRoot "run-openfl-test-suite.ps1"
$suites = @(
	"application",
	"assets",
	"bitmapdata",
	"displayobject",
	"eventdispatcher",
	"filters",
	"geom",
	"input",
	"sound",
	"stage",
	"system",
	"textfield"
)

$failures = @()

foreach ($suite in $suites) {
	try {
		& $runner -Suite $suite -Target "windows"
		Write-Host "PASS: $suite"
	} catch {
		$failures += $suite
		Write-Host "FAILED: $suite"
		Write-Host $_.Exception.Message
	}
}

Write-Host ""
Write-Host "PiratePig-related suites:"
$suites | ForEach-Object { Write-Host "- $_" }

if ($failures.Count -gt 0) {
	Write-Host ""
	Write-Host "Failing suites:"
	$failures | ForEach-Object { Write-Host "- $_" }
	throw "One or more PiratePig-related OpenFL suites failed."
}
