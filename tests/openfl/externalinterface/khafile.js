let fs = require("fs");
let path = require("path");
let project = new Project("kofl-openfl-externalinterface-tests");

project.addSources(".");

if (fs.existsSync(path.join(project.scriptdir, "src"))) {
	project.addSources("src");
}

project.addSources("../../../Sources");
project.addParameter("-lib utest");
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