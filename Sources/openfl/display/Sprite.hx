package openfl.display;

import kha.graphics2.Graphics as KhaGraphics;
import openfl.geom.Rectangle;

class Sprite extends DisplayObjectContainer {
	public var buttonMode:Bool;
	public var graphics(default, null):Graphics;
	public var hitArea:Sprite;
	public var useHandCursor:Bool;

	public function new() {
		super();
		buttonMode = false;
		graphics = new Graphics();
		useHandCursor = true;
	}

	public function startDrag(lockCenter:Bool = false, bounds:Rectangle = null):Void {}

	public function stopDrag():Void {}

	public function startTouchDrag(touchPointID:Int, lockCenter:Bool = false, bounds:Rectangle = null):Void {}

	public function stopTouchDrag(touchPointID:Int):Void {}

	override public function __render(g2:KhaGraphics, offsetX:Float, offsetY:Float):Void {
		if (!__beginRender(g2, offsetX, offsetY)) {
			return;
		}

		graphics.__render(g2, 0, 0);
		for (child in __children) {
			child.__render(g2, 0, 0);
		}

		__endRender(g2);
	}

	@:allow(openfl.display)
	override function __getLocalBounds():Rectangle {
		var result = super.__getLocalBounds();
		var graphicsBounds = graphics.__getBounds();
		var hasChildren = __children.length > 0;
		var commands:Array<Dynamic> = cast Reflect.field(graphics, "commands");
		var hasGraphics = commands != null && commands.length > 0;

		if (!hasChildren) {
			return graphicsBounds;
		}
		if (!hasGraphics) {
			return result;
		}

		var minX = Math.min(result.x, graphicsBounds.x);
		var minY = Math.min(result.y, graphicsBounds.y);
		var maxX = Math.max(result.right, graphicsBounds.right);
		var maxY = Math.max(result.bottom, graphicsBounds.bottom);
		return new Rectangle(minX, minY, maxX - minX, maxY - minY);
	}
}
