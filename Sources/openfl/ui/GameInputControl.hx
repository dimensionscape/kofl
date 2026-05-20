package openfl.ui;

import openfl.events.EventDispatcher;

class GameInputControl extends EventDispatcher {
	public var device(default, null):GameInputDevice;
	public var id(default, null):String;
	public var maxValue(default, null):Float;
	public var minValue(default, null):Float;
	public var value:Float;

	public function new(device:GameInputDevice, id:String, minValue:Float = 0, maxValue:Float = 1) {
		super();
		this.device = device;
		this.id = id;
		this.minValue = minValue;
		this.maxValue = maxValue;
		this.value = 0;
	}
}
