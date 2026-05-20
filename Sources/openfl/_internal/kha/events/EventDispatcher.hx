package openfl._internal.kha.events;

import openfl.events.Event;
import openfl.events.EventPhase;

typedef EventListener = Dynamic->Void;

private class RegisteredListener {
	public var callback:EventListener;
	public var priority:Int;
	public var useCapture:Bool;

	public function new(callback:EventListener, useCapture:Bool, priority:Int) {
		this.callback = callback;
		this.useCapture = useCapture;
		this.priority = priority;
	}
}

@:access(openfl.events.Event)
class EventDispatcher {
	var listeners:Map<String, Array<RegisteredListener>> = [];

	public function new() {}

	public function addEventListener<T>(type:String, listener:T->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		if (listener == null) {
			return;
		}

		var entries = listeners.get(type);
		if (entries == null) {
			entries = [];
			listeners.set(type, entries);
		}

		for (entry in entries) {
			if (entry.callback == listener && entry.useCapture == useCapture) {
				return;
			}
		}

		entries.push(new RegisteredListener(cast listener, useCapture, priority));
		entries.sort(function(a, b) return b.priority - a.priority);
	}

	public function removeEventListener<T>(type:String, listener:T->Void, useCapture:Bool = false):Void {
		var entries = listeners.get(type);
		if (entries == null) {
			return;
		}

		for (i in 0...entries.length) {
			var entry = entries[i];
			if (entry.callback == listener && entry.useCapture == useCapture) {
				entries.splice(i, 1);
				break;
			}
		}
	}

	public function dispatchEvent(event:Event):Bool {
		if (event.target == null) {
			event.target = this;
		}

		var ancestry = __buildAncestry();
		if (ancestry.length > 0) {
			for (i in 0...ancestry.length) {
				var dispatcher = ancestry[ancestry.length - 1 - i];
				if (event.__isCanceled) {
					break;
				}
				dispatcher.__dispatchEvent(event, EventPhase.CAPTURING_PHASE);
			}
		}

		if (!event.__isCanceled) {
			__dispatchEvent(event, EventPhase.AT_TARGET);
		}

		if (event.bubbles && !event.__isCanceled) {
			for (dispatcher in ancestry) {
				if (event.__isCanceled) {
					break;
				}
				dispatcher.__dispatchEvent(event, EventPhase.BUBBLING_PHASE);
			}
		}

		return !event.isDefaultPrevented();
	}

	public function hasEventListener(type:String):Bool {
		var entries = listeners.get(type);
		return entries != null && entries.length > 0;
	}

	public function willTrigger(type:String):Bool {
		if (hasEventListener(type)) {
			return true;
		}

		var parent = __getEventParent();
		return parent != null ? parent.willTrigger(type) : false;
	}

	function __dispatchEvent(event:Event, phase:EventPhase):Void {
		var entries = listeners.get(event.type);
		if (entries == null || entries.length == 0) {
			return;
		}

		event.currentTarget = this;
		event.eventPhase = phase;

		var snapshot = entries.copy();
		for (entry in snapshot) {
			if (__shouldDispatchToListener(entry, phase)) {
				entry.callback(event);
				if (event.__isCanceledNow) {
					break;
				}
			}
		}
	}

	function __shouldDispatchToListener(entry:RegisteredListener, phase:EventPhase):Bool {
		return switch (phase) {
			case CAPTURING_PHASE: entry.useCapture;
			case BUBBLING_PHASE, AT_TARGET: !entry.useCapture;
			default: false;
		}
	}

	function __buildAncestry():Array<EventDispatcher> {
		var result:Array<EventDispatcher> = [];
		var current = __getEventParent();

		while (current != null) {
			result.push(current);
			current = current.__getEventParent();
		}

		return result;
	}

	function __getEventParent():EventDispatcher {
		return null;
	}
}
