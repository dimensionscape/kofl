package openfl.display;

import openfl.events.EventDispatcher;
import openfl.events.UncaughtErrorEvents;
import openfl.system.ApplicationDomain;
import openfl.utils.ByteArray;

class LoaderInfo extends EventDispatcher {
	public var applicationDomain:ApplicationDomain;
	public var bytes:ByteArray;
	public var bytesLoaded:Int = 0;
	public var bytesTotal:Int = 0;
	public var content:Dynamic;
	public var contentType:String;
	public var frameRate:Float = 0;
	public var height:Int = -1;
	public var loader:Loader;
	public var loaderURL:String;
	public var parameters:Dynamic;
	public var parentAllowsChild:Bool = true;
	public var sameDomain:Bool = true;
	public var sharedEvents:EventDispatcher;
	public var uncaughtErrorEvents(default, null):UncaughtErrorEvents;
	public var url:String;
	public var width:Int = -1;

	public function new() {
		super();
		applicationDomain = ApplicationDomain.currentDomain;
		sharedEvents = new EventDispatcher();
		uncaughtErrorEvents = new UncaughtErrorEvents();
	}

	public static function create(content:Dynamic, loader:Loader = null):LoaderInfo {
		var loaderInfo = new LoaderInfo();
		loaderInfo.content = content;
		loaderInfo.loader = loader;
		return loaderInfo;
	}
}
