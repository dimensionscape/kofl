let project = new Project("kofl-sample-handling-mouse-events");
const { configureSampleProject } = require(project.scriptdir + "/../common/sample-helper.js");

configureSampleProject(project, {
	sourceDir: "../../../vendor/openfl-samples/features/events/HandlingMouseEvents/Source",
	libs: ["actuate"],
	assets: [
		{
			match: "../../../vendor/openfl-samples/features/events/HandlingMouseEvents/Assets/**",
			options: {
				name: "assets/{dir}/{name}",
				nameBaseDir: "../../../vendor/openfl-samples/features/events/HandlingMouseEvents/Assets",
				namePathSeparator: "/",
				readable: true
			}
		}
	]
});

resolve(project);
