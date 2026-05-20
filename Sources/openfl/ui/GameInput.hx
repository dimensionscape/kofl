package openfl.ui;

import openfl.events.EventDispatcher;
import openfl.events.EventType;
import openfl.events.GameInputEvent;

class GameInput extends EventDispatcher {
	public static var isSupported(default, null) = false;
	public static var numDevices(default, null) = 0;

	static var __deviceList:Array<GameInputDevice> = [];

	public function new() {
		super();
	}

	override public function addEventListener<T>(type:EventType<T>, listener:T->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		super.addEventListener(type, listener, useCapture, priority, useWeakReference);

		if (type == GameInputEvent.DEVICE_ADDED) {
			for (device in __deviceList) {
				dispatchEvent(new GameInputEvent(GameInputEvent.DEVICE_ADDED, true, false, device));
			}
		}
	}

	public static function getDeviceAt(index:Int):GameInputDevice {
		return index >= 0 && index < __deviceList.length ? __deviceList[index] : null;
	}
}
