$ErrorActionPreference = "Stop"

$samples = @(
	@{ Root = "samples/openfl-samples/drawing-shapes"; Main = "Bootstrap"; Name = "drawing-shapes" },
	@{ Root = "samples/openfl-samples/displaying-a-bitmap"; Main = "Bootstrap"; Name = "displaying-a-bitmap" },
	@{ Root = "samples/openfl-samples/using-bitmap-data"; Main = "Bootstrap"; Name = "using-bitmap-data" },
	@{ Root = "samples/openfl-samples/adding-text"; Main = "Bootstrap"; Name = "adding-text" },
	@{ Root = "samples/openfl-samples/handling-mouse-events"; Main = "Bootstrap"; Name = "handling-mouse-events" },
	@{ Root = "samples/openfl-samples/handling-keyboard-events"; Main = "Bootstrap"; Name = "handling-keyboard-events" },
	@{ Root = "samples/openfl-samples/creating-a-main-loop"; Main = "Bootstrap"; Name = "creating-a-main-loop" },
	@{ Root = "samples/openfl-samples/pirate-pig"; Main = "Bootstrap"; Name = "pirate-pig" }
)

foreach ($sample in $samples) {
	& (Join-Path $PSScriptRoot "build-openfl-sample.ps1") `
		-SampleRoot $sample.Root `
		-MainClass $sample.Main `
		-OutputName $sample.Name `
		-Target "windows"
}
