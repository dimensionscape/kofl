package openfl.display;

import openfl.events.UncaughtErrorEvent;

class Stage extends openfl._internal.kha.display.Stage {
	public var align:StageAlign = StageAlign.TOP_LEFT;
	public var allowsFullScreen(default, null):Bool = false;
	public var allowsFullScreenInteractive(default, null):Bool = false;
	public var application:Dynamic;
	public var color(get, set):Null<Int>;
	public var displayState:StageDisplayState = StageDisplayState.NORMAL;
	public var focus(get, set):InteractiveObject;
	public var frameRate:Float = 60;
	public var quality:StageQuality = StageQuality.HIGH;
	public var scaleMode:StageScaleMode = StageScaleMode.SHOW_ALL;
	public var stageFocusRect:Bool = true;
	public var context3D:Dynamic;
	public var window:Dynamic;
	public var __mouseX:Float = 0;
	public var __mouseY:Float = 0;
	public var __renderer:Dynamic;

	var __color:Int;
	var __focus:InteractiveObject;

	public function new(stageWidth:Int, stageHeight:Int, backgroundColor:kha.Color) {
		super(stageWidth, stageHeight, backgroundColor);
		__color = (backgroundColor.Rb << 16) | (backgroundColor.Gb << 8) | backgroundColor.Bb;
	}

	public function invalidate():Void {}

	public function __renderAfterEvent():Void {}

	public function __resolveInteractiveTarget(stageX:Float, stageY:Float):InteractiveObject {
		for (i in 0...__children.length) {
			var child:DisplayObject = cast __children[__children.length - 1 - i];
			var target = __resolveInteractiveTargetIn(child, stageX, stageY);
			if (target != null) {
				return target;
			}
		}

		return null;
	}

	override public function __handleError(error:Dynamic):Void {
		__uncaughtErrorEvents.dispatchEvent(new UncaughtErrorEvent(UncaughtErrorEvent.UNCAUGHT_ERROR, true, true, error));
	}

	function get_color():Null<Int> {
		return __color;
	}

	function get_focus():InteractiveObject {
		return __focus;
	}

	function set_color(value:Null<Int>):Null<Int> {
		__color = value == null ? 0 : value;
		if (value != null) {
			backgroundColor = kha.Color.fromBytes((value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF);
		}
		return value;
	}

	function set_focus(value:InteractiveObject):InteractiveObject {
		if (__focus == value) {
			return value;
		}

		var previous = __focus;
		__focus = value;

		if (previous != null) {
			previous.dispatchEvent(new openfl.events.FocusEvent(openfl.events.FocusEvent.FOCUS_OUT, true, false, value));
		}

		if (value != null) {
			value.dispatchEvent(new openfl.events.FocusEvent(openfl.events.FocusEvent.FOCUS_IN, true, false, previous));
		}

		return value;
	}

	function __resolveInteractiveTargetIn(object:DisplayObject, stageX:Float, stageY:Float):InteractiveObject {
		if (object == null || !object.visible) {
			return null;
		}

		if (Std.isOfType(object, DisplayObjectContainer)) {
			var container:DisplayObjectContainer = cast object;
			if (!container.mouseChildren) {
				return __canTarget(container, stageX, stageY) ? cast container : null;
			}

			for (i in 0...container.__children.length) {
				var child:DisplayObject = cast container.__children[container.__children.length - 1 - i];
				var nested = __resolveInteractiveTargetIn(child, stageX, stageY);
				if (nested != null) {
					return nested;
				}
			}
		}

		return __canTarget(object, stageX, stageY) ? cast object : null;
	}

	function __canTarget(object:DisplayObject, stageX:Float, stageY:Float):Bool {
		if (!Std.isOfType(object, InteractiveObject)) {
			return false;
		}

		var interactive:InteractiveObject = cast object;
		if (!interactive.mouseEnabled) {
			return false;
		}

		return interactive.hitTestPoint(stageX, stageY, true);
	}
}
