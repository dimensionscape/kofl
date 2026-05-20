package openfl.events;

class FullScreenEvent extends ActivityEvent {
	public static inline var FULL_SCREEN:EventType<FullScreenEvent> = "fullScreen";
	public static inline var FULL_SCREEN_INTERACTIVE_ACCEPTED:EventType<FullScreenEvent> = "fullScreenInteractiveAccepted";

	public var fullScreen:Bool;
	public var interactive:Bool;

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false, fullScreen:Bool = false, interactive:Bool = false) {
		super(type, bubbles, cancelable);
		this.fullScreen = fullScreen;
		this.interactive = interactive;
	}

	override public function clone():FullScreenEvent {
		var event = new FullScreenEvent(type, bubbles, cancelable, fullScreen, interactive);
		event.target = target;
		event.currentTarget = currentTarget;
		event.eventPhase = eventPhase;
		return event;
	}

	override public function toString():String {
		return __formatToString("FullScreenEvent", ["type", "bubbles", "cancelable", "fullScreen", "interactive"]);
	}

	@:noCompletion private override function __init():Void {
		super.__init();
		fullScreen = false;
		interactive = false;
	}
}
