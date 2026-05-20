package openfl.display;

#if !flash
import openfl.media.SoundTransform;

class SimpleButton extends InteractiveObject {
	public var downState(get, set):DisplayObject;
	public var enabled:Bool;
	public var hitTestState(get, set):DisplayObject;
	public var overState(get, set):DisplayObject;
	public var soundTransform(get, set):SoundTransform;
	public var trackAsMenu:Bool;
	public var upState(get, set):DisplayObject;
	public var useHandCursor:Bool;

	var __currentState:DisplayObject;
	var __downState:DisplayObject;
	var __hitTestState:DisplayObject;
	var __overState:DisplayObject;
	var __soundTransform:SoundTransform;
	var __upState:DisplayObject;

	public function new(upState:DisplayObject = null, overState:DisplayObject = null, downState:DisplayObject = null, hitTestState:DisplayObject = null) {
		super();
		enabled = true;
		trackAsMenu = false;
		useHandCursor = true;
		__upState = upState;
		__overState = overState;
		__downState = downState;
		__hitTestState = hitTestState;
		__currentState = __upState;
	}

	function get_downState():DisplayObject {
		return __downState;
	}

	function set_downState(value:DisplayObject):DisplayObject {
		__downState = value;
		return value;
	}

	function get_hitTestState():DisplayObject {
		return __hitTestState;
	}

	function set_hitTestState(value:DisplayObject):DisplayObject {
		__hitTestState = value;
		return value;
	}

	function get_overState():DisplayObject {
		return __overState;
	}

	function set_overState(value:DisplayObject):DisplayObject {
		__overState = value;
		return value;
	}

	function get_soundTransform():SoundTransform {
		if (__soundTransform == null) {
			__soundTransform = new SoundTransform();
		}
		return __soundTransform;
	}

	function set_soundTransform(value:SoundTransform):SoundTransform {
		__soundTransform = value == null ? new SoundTransform() : new SoundTransform(value.volume, value.pan);
		return value;
	}

	function get_upState():DisplayObject {
		return __upState;
	}

	function set_upState(value:DisplayObject):DisplayObject {
		__upState = value;
		return value;
	}
}
#else
typedef SimpleButton = flash.display.SimpleButton;
typedef SimpleButton2 = flash.display.SimpleButton.SimpleButton2;
#end
