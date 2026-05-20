let project = new Project("kofl-sample-displaying-a-bitmap");
const { configureSampleProject } = require(project.scriptdir + "/../common/sample-helper.js");

configureSampleProject(project, {
	sourceDir: "../../../vendor/openfl-samples/features/display/DisplayingABitmap/Source",
	assets: [
		{
			match: "../../../vendor/openfl-samples/features/display/DisplayingABitmap/Assets/**",
			options: {
				name: "assets/{dir}/{name}",
				nameBaseDir: "../../../vendor/openfl-samples/features/display/DisplayingABitmap/Assets",
				namePathSeparator: "/",
				readable: true
			}
		}
	]
});

resolve(project);
