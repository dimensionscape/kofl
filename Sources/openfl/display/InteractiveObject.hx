package openfl.display;

import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.geom.Rectangle;

class InteractiveObject extends DisplayObject {
	@:keep public var doubleClickEnabled:Bool;
	@:keep public var focusRect:Null<Bool>;
	@:keep public var mouseEnabled:Bool;
	@:keep public var needsSoftKeyboard:Bool;
	@:keep public var softKeyboardInputAreaOfInterest:Rectangle;
	@:keep public var tabEnabled(get, set):Bool;
	@:keep public var tabIndex(get, set):Int;

	var __tabEnabled:Null<Bool> = null;
	var __tabIndex = -1;

	public function new() {
		super();
		doubleClickEnabled = false;
		mouseEnabled = true;
		needsSoftKeyboard = false;
	}

	#if !openfl_strict
	public function requestSoftKeyboard():Bool {
		return false;
	}
	#end

	function get_tabEnabled():Bool {
		return __tabEnabled;
	}

	function set_tabEnabled(value:Bool):Bool {
		if (__tabEnabled != value) {
			__tabEnabled = value;
			dispatchEvent(new Event(Event.TAB_ENABLED_CHANGE, true, false));
		}
		return value;
	}

	function get_tabIndex():Int {
		return __tabIndex;
	}

	function set_tabIndex(value:Int):Int {
		if (value < -1) {
			throw new RangeError("Parameter tabIndex must be a non-negative number; got " + value);
		}

		if (__tabIndex != value) {
			__tabIndex = value;
			dispatchEvent(new Event(Event.TAB_INDEX_CHANGE, true, false));
		}
		return value;
	}
}
