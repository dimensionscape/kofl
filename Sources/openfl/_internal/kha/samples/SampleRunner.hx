package openfl._internal.kha.samples;

import openfl.Lib;
import openfl.display.DisplayObjectContainer;

class SampleRunner {
	public static function run(title:String, width:Int, height:Int, backgroundColor:Int, createRoot:Void->DisplayObjectContainer):Void {
		Lib.start({
			title: title,
			width: width,
			height: height,
			backgroundColor: backgroundColor
		}, createRoot);
	}
}
