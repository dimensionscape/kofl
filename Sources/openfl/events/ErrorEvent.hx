package openfl.events;

#if !flash
class ErrorEvent extends TextEvent {
	public static inline var ERROR:EventType<ErrorEvent> = "error";

	@:keep public var errorID:Int;

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false, text:String = "", id:Int = 0) {
		super(type, bubbles, cancelable, text);
		errorID = id;
	}

	override public function clone():ErrorEvent {
		var event = new ErrorEvent(type, bubbles, cancelable, text, errorID);
		event.target = target;
		event.currentTarget = currentTarget;
		event.eventPhase = eventPhase;
		return event;
	}
}
#else
typedef ErrorEvent = flash.events.ErrorEvent;
#end
