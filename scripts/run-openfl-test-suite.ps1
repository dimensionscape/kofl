param(
	[Parameter(Mandatory = $true)][string]$Suite,
	[string]$Target = "windows",
	[int]$TimeoutSeconds = 90
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$builder = Join-Path $PSScriptRoot "build-openfl-test-suite.ps1"
$targetDir = Join-Path $root ("build\\tests\\openfl-" + $Suite + "-" + $Target)

& $builder -Suite $Suite -Target $Target

if ($Target -ne "windows") {
	throw "run-openfl-test-suite.ps1 currently supports only the windows target."
}

$exe = Get-ChildItem (Join-Path $targetDir "windows") -Filter *.exe -File | Select-Object -First 1

if ($null -eq $exe) {
	throw "Could not locate a windows test executable for suite '$Suite' in '$targetDir\\windows'"
}

$resultPath = Join-Path $targetDir ("kofl-utest-result-" + $Suite + ".json")
if (Test-Path $resultPath) {
	Remove-Item $resultPath -Force
}
$timerTracePath = Join-Path $targetDir ("kofl-timer-trace-" + $Suite + ".log")
if (Test-Path $timerTracePath) {
	Remove-Item $timerTracePath -Force
}

$env:KOFL_UTEST_RESULT_PATH = $resultPath
$env:KOFL_TIMER_TRACE_PATH = $timerTracePath
$process = Start-Process -FilePath $exe.FullName -WorkingDirectory $exe.DirectoryName -WindowStyle Hidden -PassThru

try {
	$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
	$result = $null

	while ((Get-Date) -lt $deadline) {
		if (Test-Path $resultPath) {
			try {
				$result = Get-Content -Raw $resultPath | ConvertFrom-Json
				if ($result.status -eq "complete") {
					break
				}
			} catch {}
		}

		if ($process.HasExited) {
			break
		}

		Start-Sleep -Milliseconds 250
	}

	if ($null -eq $result -and (Test-Path $resultPath)) {
		$result = Get-Content -Raw $resultPath | ConvertFrom-Json
	}

	if ($null -eq $result) {
		if (-not $process.HasExited) {
			Stop-Process -Id $process.Id -Force
		}

		throw "Suite '$Suite' did not produce a result file within $TimeoutSeconds seconds."
	}

	if (-not $process.HasExited) {
		$process.WaitForExit(5000) | Out-Null
		if (-not $process.HasExited) {
			Stop-Process -Id $process.Id -Force
		}
	}

	$exitCode = if ($process.HasExited) { $process.ExitCode } else { $null }

	Write-Host ("SUITE: " + $Suite)
	Write-Host ("PASSED: " + $result.passed)
	Write-Host ("FAILED ASSERTIONS: " + $result.failed)
	Write-Host ("WARNINGS: " + $result.warnings)
	Write-Host ("IGNORED: " + $result.ignored)
	Write-Host ("STATUS: " + $result.status)
	Write-Host ("PHASE: " + $result.phase)
	Write-Host ("EXIT CODE: " + $exitCode)
	if (Test-Path $timerTracePath) {
		Write-Host ("TIMER TRACE: " + $timerTracePath)
	}

	if ($result.status -ne "complete") {
		throw "Suite '$Suite' did not complete. Exit code: $exitCode. Phase: $($result.phase). Last known progress: $($result.completed)/$($result.total). Current: $($result.currentCase).$($result.currentMethod). Last completed: $($result.lastCompletedCase).$($result.lastCompletedMethod)."
	}

	if ($null -ne $exitCode -and $exitCode -ne 0) {
		throw "Suite '$Suite' exited abnormally with exit code $exitCode despite reporting completion."
	}

	if (-not $result.passed) {
		Write-Host ""
		Write-Host "Failure details:"
		foreach ($failure in $result.failures) {
			Write-Host ("- " + $failure.caseName + "." + $failure.method + " [" + $failure.kind + "] " + $failure.message)
		}
		throw "Suite '$Suite' reported failing assertions."
	}
} finally {
	Remove-Item Env:KOFL_UTEST_RESULT_PATH -ErrorAction SilentlyContinue
	Remove-Item Env:KOFL_TIMER_TRACE_PATH -ErrorAction SilentlyContinue
}
