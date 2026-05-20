function configureSampleProject(project, config) {
	project.addSources(".");
	project.addSources("../../../Sources");
	project.addSources("../../../vendor/openfl-flash-externs/src");
	project.addSources(config.sourceDir);
	project.addAssets("C:/Windows/Fonts/arial.ttf", { name: "default_font" });
	project.addParameter("-dce full");
	project.addParameter("-D openfl");
	project.addParameter("--macro openfl.utils._internal.ExtraParamsMacro.include()");

	if (config.libs) {
		for (const lib of config.libs) {
			project.addParameter("-lib " + lib);
		}
	}

	if (config.assets) {
		for (const asset of config.assets) {
			project.addAssets(asset.match, asset.options || {});
		}
	}
}

module.exports = { configureSampleProject };
