let project = new Project("kofl");

project.addSources("Sources");
project.addSources("vendor/openfl-flash-externs/src");
project.addAssets("C:/Windows/Fonts/arial.ttf", { name: "default_font" });
project.addParameter("-dce full");
project.addParameter("-D openfl");
project.addParameter("--macro openfl.utils._internal.ExtraParamsMacro.include()");

resolve(project);
