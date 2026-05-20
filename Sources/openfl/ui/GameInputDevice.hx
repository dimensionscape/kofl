package openfl.ui;

class GameInputDevice {
	public static inline var MAX_BUFFER_SIZE:Int = 32000;

	public var enabled:Bool = true;
	public var id(default, null):String;
	public var name(default, null):String;
	public var numControls(get, never):Int;
	public var sampleInterval:Int = 0;

	var __controls:Array<GameInputControl>;

	public function new(id:String = "", name:String = "") {
		this.id = id;
		this.name = name;
		__controls = [];
	}

	public function getCachedSamples(data:Dynamic, append:Bool = false):Int {
		return 0;
	}

	public function getControlAt(index:Int):GameInputControl {
		return index >= 0 && index < __controls.length ? __controls[index] : null;
	}

	public function startCachingSamples(numSamples:Int, controls:Vector<String>):Void {}

	public function stopCachingSamples():Void {}

	function get_numControls():Int {
		return __controls.length;
	}
}
