package openfl.events;

#if !flash
class UncaughtErrorEvent extends ErrorEvent {
	public static inline var UNCAUGHT_ERROR:EventType<UncaughtErrorEvent> = "uncaughtError";

	@:keep public var error:Dynamic;

	public function new(type:String, bubbles:Bool = true, cancelable:Bool = true, error:Dynamic = null) {
		super(type, bubbles, cancelable);
		this.error = error;
	}

	override public function clone():UncaughtErrorEvent {
		var event = new UncaughtErrorEvent(type, bubbles, cancelable, error);
		event.target = target;
		event.currentTarget = currentTarget;
		event.eventPhase = eventPhase;
		return event;
	}
}
#else
typedef UncaughtErrorEvent = flash.events.UncaughtErrorEvent;
#end
