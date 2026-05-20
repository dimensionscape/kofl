let project = new Project("kofl-sample-adding-text");
const { configureSampleProject } = require(project.scriptdir + "/../common/sample-helper.js");

configureSampleProject(project, {
	sourceDir: "../../../vendor/openfl-samples/features/text/AddingText/Source",
	assets: [
		{
			match: "../../../vendor/openfl-samples/features/text/AddingText/Assets/**",
			options: {
				name: "assets/{dir}/{name}",
				nameBaseDir: "../../../vendor/openfl-samples/features/text/AddingText/Assets",
				namePathSeparator: "/"
			}
		}
	]
});

resolve(project);
