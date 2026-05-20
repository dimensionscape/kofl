let project = new Project("kofl-sample-creating-a-main-loop");
const { configureSampleProject } = require(project.scriptdir + "/../common/sample-helper.js");

configureSampleProject(project, {
	sourceDir: "../../../vendor/openfl-samples/features/events/CreatingAMainLoop/Source"
});

resolve(project);
