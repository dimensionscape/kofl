let project = new Project("kofl-sample-pirate-pig");
const { configureSampleProject } = require(project.scriptdir + "/../common/sample-helper.js");

configureSampleProject(project, {
	sourceDir: "../../../vendor/openfl-samples/demos/PiratePig/Source",
	libs: ["actuate"],
	assets: [
		{
			match: "../../../vendor/openfl-samples/demos/PiratePig/Assets/fonts/**",
			options: {
				name: "fonts/{dir}/{name}",
				nameBaseDir: "../../../vendor/openfl-samples/demos/PiratePig/Assets/fonts",
				namePathSeparator: "/"
			}
		},
		{
			match: "../../../vendor/openfl-samples/demos/PiratePig/Assets/images/**",
			options: {
				name: "images/{dir}/{name}",
				nameBaseDir: "../../../vendor/openfl-samples/demos/PiratePig/Assets/images",
				namePathSeparator: "/",
				readable: true
			}
		},
		{ match: "../../../vendor/openfl-samples/demos/PiratePig/Assets/sounds/3.wav", options: { name: "sound3" } },
		{ match: "../../../vendor/openfl-samples/demos/PiratePig/Assets/sounds/4.wav", options: { name: "sound4" } },
		{ match: "../../../vendor/openfl-samples/demos/PiratePig/Assets/sounds/5.wav", options: { name: "sound5" } },
		{ match: "../../../vendor/openfl-samples/demos/PiratePig/Assets/sounds/theme.wav", options: { name: "soundTheme" } }
	]
});

resolve(project);
