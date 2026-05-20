$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$testsRoot = Join-Path $root "tests\\openfl"
$builder = Join-Path $PSScriptRoot "build-openfl-test-suite.ps1"
$failures = @()
$successes = @()

Get-ChildItem $testsRoot -Directory | Sort-Object Name | ForEach-Object {
	$suiteName = $_.Name
	$suiteRoot = $_.FullName
	$hasEntry = (Test-Path (Join-Path $suiteRoot "Tests.hx")) -or (Test-Path (Join-Path $suiteRoot "src\\Main.hx"))

	if ($hasEntry) {
		try {
			& $builder -Suite $suiteName -Target "html5"
			$successes += $suiteName
			Write-Host "PASS: $suiteName"
		} catch {
			$failures += $suiteName
			Write-Host "FAILED: $suiteName"
			Write-Host $_.Exception.Message
		}
	} else {
		Write-Host "Skipping placeholder upstream suite $suiteName (no Tests.hx/src/Main.hx)"
	}
}

Write-Host ""
Write-Host "Passing suites:"
$successes | Sort-Object | ForEach-Object { Write-Host "- $_" }

if ($failures.Count -gt 0) {
	Write-Host ""
	Write-Host "Failing suites:"
	$failures | Sort-Object | ForEach-Object { Write-Host "- $_" }
	throw "One or more OpenFL test suites failed to build."
}
