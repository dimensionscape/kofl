package openfl._internal.kha.display;

import kha.graphics2.Graphics;
import kha.math.FastMatrix3;
import openfl._internal.kha.events.EventDispatcher;
import openfl.events.Event;

class DisplayObject extends EventDispatcher {
	static var DEG_TO_RAD = Math.PI / 180;

	public var alpha(get, set):Float;
	public var x:Float = 0;
	public var y:Float = 0;
	public var name:String;
	public var parent(default, null):Dynamic = null;
	public var rotation:Float = 0;
	public var scaleX:Float = 1.0;
	public var scaleY:Float = 1.0;
	public var stage(get, never):openfl.display.Stage;
	public var visible:Bool = true;
	public var width(get, set):Float;
	public var height(get, set):Float;

	var __alpha:Float = 1.0;

	public function new() {
		super();
	}

	@:allow(openfl.display)
	function setParent(value:DisplayObject):Void {
		parent = value;
	}

	override function __getEventParent():EventDispatcher {
		return parent;
	}

	function get_stage():openfl.display.Stage {
		var current:DisplayObject = this;
		while (current != null) {
			if (Std.isOfType(current, Stage)) {
				return cast current;
			}
			current = current.parent;
		}
		return openfl.Lib.__constructionStage;
	}

	function get_width():Float {
		return __getNaturalWidth() * scaleX;
	}

	function set_width(value:Float):Float {
		var naturalWidth = __getNaturalWidth();
		if (naturalWidth != 0) {
			scaleX = value / naturalWidth;
		}
		return value;
	}

	function get_height():Float {
		return __getNaturalHeight() * scaleY;
	}

	function set_height(value:Float):Float {
		var naturalHeight = __getNaturalHeight();
		if (naturalHeight != 0) {
			scaleY = value / naturalHeight;
		}
		return value;
	}

	function get_alpha():Float {
		return __alpha;
	}

	function set_alpha(value:Float):Float {
		if (value != value) {
			value = 0.0;
		} else if (value > 1.0) {
			value = 1.0;
		} else if (value < 0.0) {
			value = 0.0;
		}

		return __alpha = value;
	}

	public function __update(deltaTime:Float):Void {}

	public function __render(g2:Graphics, offsetX:Float, offsetY:Float):Void {}

	public function __getNaturalWidth():Float {
		return 0;
	}

	public function __getNaturalHeight():Float {
		return 0;
	}

	public function __beginRender(g2:Graphics, offsetX:Float, offsetY:Float):Bool {
		if (!visible || alpha <= 0) {
			return false;
		}

		var current = g2.transformation;
		var local = FastMatrix3.translation(offsetX + x, offsetY + y)
			.multmat(FastMatrix3.rotation(rotation * DEG_TO_RAD))
			.multmat(FastMatrix3.scale(scaleX, scaleY));
		var matrix = current.multmat(local);
		g2.pushTransformation(matrix);
		g2.pushOpacity(g2.opacity * alpha);
		return true;
	}

	public function __endRender(g2:Graphics):Void {
		g2.popOpacity();
		g2.popTransformation();
	}

	public function __broadcastAddedToStage():Void {
		dispatchEvent(new Event(Event.ADDED_TO_STAGE));
	}

	public function __broadcastRemovedFromStage():Void {
		dispatchEvent(new Event(Event.REMOVED_FROM_STAGE));
	}

	public function __broadcastEnterFrame():Void {
		dispatchEvent(new Event(Event.ENTER_FRAME));
	}
}
