let project = new Project("kofl-sample-drawing-shapes");
const { configureSampleProject } = require(project.scriptdir + "/../common/sample-helper.js");

configureSampleProject(project, {
	sourceDir: "../../../vendor/openfl-samples/features/display/DrawingShapes/Source"
});

resolve(project);
