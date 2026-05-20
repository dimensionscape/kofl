let project = new Project("kofl-sample-using-bitmap-data");
const { configureSampleProject } = require(project.scriptdir + "/../common/sample-helper.js");

configureSampleProject(project, {
	sourceDir: "../../../vendor/openfl-samples/features/display/UsingBitmapData/Source",
	assets: [
		{
			match: "../../../vendor/openfl-samples/features/display/UsingBitmapData/Assets/**",
			options: {
				name: "assets/{dir}/{name}",
				nameBaseDir: "../../../vendor/openfl-samples/features/display/UsingBitmapData/Assets",
				namePathSeparator: "/",
				readable: true
			}
		}
	]
});

resolve(project);
