package openfl.events;

import openfl.ui.GameInputDevice;

class GameInputEvent extends Event {
	public static inline var DEVICE_ADDED:EventType<GameInputEvent> = "deviceAdded";
	public static inline var DEVICE_REMOVED:EventType<GameInputEvent> = "deviceRemoved";
	public static inline var DEVICE_UNUSABLE:EventType<GameInputEvent> = "deviceUnusable";

	public var device(default, null):GameInputDevice;

	public function new(type:String, bubbles:Bool = true, cancelable:Bool = false, device:GameInputDevice = null) {
		super(type, bubbles, cancelable);
		this.device = device;
	}

	override public function clone():GameInputEvent {
		var event = new GameInputEvent(type, bubbles, cancelable, device);
		event.target = target;
		event.currentTarget = currentTarget;
		event.eventPhase = eventPhase;
		return event;
	}
}
