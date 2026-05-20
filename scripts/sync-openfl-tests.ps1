param(
	[string]$UpstreamRoot
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$defaultUpstreamRoot = Join-Path (Split-Path -Parent $root) "openfl\tests"
$sourceRoot = if ($UpstreamRoot) { $UpstreamRoot } else { $defaultUpstreamRoot }
$destRoot = Join-Path $root "tests\openfl"

if (-not (Test-Path $sourceRoot)) {
	throw "Cannot find upstream OpenFL tests at '$sourceRoot'"
}

$khafileTemplate = @'
let fs = require("fs");
let path = require("path");
let project = new Project("__PROJECT_NAME__");

project.addSources(".");

if (fs.existsSync(path.join(project.scriptdir, "src"))) {
	project.addSources("src");
}

project.addSources("../../../Sources");
__UTEST_LINE__
project.addAssets("C:/Windows/Fonts/arial.ttf", { name: "default_font" });

const assetRoots = [
	{ dir: "assets", publicRoot: "assets" },
	{ dir: "fonts", publicRoot: "fonts" },
	{ dir: "images", publicRoot: "images" },
	{ dir: "src/assets", publicRoot: "assets" },
	{ dir: "src/fonts", publicRoot: "fonts" },
	{ dir: "src/images", publicRoot: "images" }
];

for (const assetRoot of assetRoots) {
	if (fs.existsSync(path.join(project.scriptdir, assetRoot.dir))) {
		project.addAssets(assetRoot.dir + "/**", {
			name: assetRoot.publicRoot + "/{dir}/{name}",
			nameBaseDir: assetRoot.dir,
			namePathSeparator: "/",
			readable: true
		});
	}
}

resolve(project);
'@

Get-ChildItem $sourceRoot -Directory | ForEach-Object {
	$suiteName = $_.Name
	$destSuite = Join-Path $destRoot $suiteName

	if (Test-Path $destSuite) {
		Remove-Item $destSuite -Recurse -Force
	}

	Copy-Item $_.FullName $destSuite -Recurse -Force

	$testsMain = Test-Path (Join-Path $destSuite "Tests.hx")
	$functionalMain = Test-Path (Join-Path $destSuite "src\\Main.hx")

	if ($testsMain -or $functionalMain) {
		$projectName = "kofl-openfl-$suiteName-tests"
		$utestLine = if ($testsMain) { 'project.addParameter("-lib utest");' } else { "" }
		$khafileContent = $khafileTemplate.Replace("__PROJECT_NAME__", $projectName).Replace("__UTEST_LINE__", $utestLine)
		Set-Content -Path (Join-Path $destSuite "khafile.js") -Value $khafileContent -NoNewline
	}
}
