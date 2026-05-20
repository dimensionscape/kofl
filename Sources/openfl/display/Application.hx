package openfl.display;

import openfl._internal.kha.ApplicationBackend;

typedef ApplicationConfig = {
	var title:String;
	var width:Int;
	var height:Int;
	var backgroundColor:Int;
}

class Application {
	public static var current:Application;

	public var backend(default, null):ApplicationBackend;
	public var stage(get, never):Stage;
	public var window:Dynamic;

	public function new() {
		current = this;
	}

	public function create(config:ApplicationConfig, createRoot:Void->DisplayObjectContainer):Void {
		var self = this;
		openfl.Lib.__startWithApplication(this, config, function(app:ApplicationBackend) {
			backend = app;
			openfl.Lib.__constructionStage = cast app.stage;
			openfl.Lib.__constructionCurrent = new DisplayObjectContainer();
			var root:DisplayObjectContainer = null;
			try {
				root = createRoot();
			} catch (e:Dynamic) {
				openfl.Lib.__constructionStage = null;
				openfl.Lib.__constructionCurrent = null;
				throw e;
			}
			openfl.Lib.__constructionStage = null;
			openfl.Lib.__constructionCurrent = null;
			if (root.__loaderInfo == null) {
				root.__loaderInfo = LoaderInfo.create(root);
			}
			root.__loaderInfo.width = config.width;
			root.__loaderInfo.height = config.height;
			openfl.Lib.current = root;
			app.stage.addChild(root);
		});
	}

	function get_stage():Stage {
		return backend != null ? cast backend.stage : null;
	}
}
