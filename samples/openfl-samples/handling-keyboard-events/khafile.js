let project = new Project("kofl-sample-handling-keyboard-events");
const { configureSampleProject } = require(project.scriptdir + "/../common/sample-helper.js");

configureSampleProject(project, {
	sourceDir: "../../../vendor/openfl-samples/features/events/HandlingKeyboardEvents/Source",
	assets: [
		{
			match: "../../../vendor/openfl-samples/features/events/HandlingKeyboardEvents/Assets/**",
			options: {
				name: "assets/{dir}/{name}",
				nameBaseDir: "../../../vendor/openfl-samples/features/events/HandlingKeyboardEvents/Assets",
				namePathSeparator: "/",
				readable: true
			}
		}
	]
});

resolve(project);
