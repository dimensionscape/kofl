package openfl.events;

class ActivityEvent extends Event {
	public static inline var ACTIVITY:EventType<ActivityEvent> = "activity";

	public var activating:Bool;

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false, activating:Bool = false) {
		super(type, bubbles, cancelable);
		this.activating = activating;
	}

	override public function clone():ActivityEvent {
		var event = new ActivityEvent(type, bubbles, cancelable, activating);
		event.target = target;
		event.currentTarget = currentTarget;
		event.eventPhase = eventPhase;
		return event;
	}

	override public function toString():String {
		return __formatToString("ActivityEvent", ["type", "bubbles", "cancelable", "activating"]);
	}

	@:noCompletion private override function __init():Void {
		super.__init();
		activating = false;
	}
}
