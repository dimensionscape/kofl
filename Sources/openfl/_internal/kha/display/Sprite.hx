package openfl._internal.kha.display;

import kha.graphics2.Graphics as KhaGraphics;

class Sprite extends DisplayObjectContainer {
	public var graphics(default, null):Graphics;

	public function new() {
		super();
		graphics = new Graphics();
	}

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

	override public function __getNaturalWidth():Float {
		return Math.max(graphics.__boundsWidth, super.__getNaturalWidth());
	}

	override public function __getNaturalHeight():Float {
		return Math.max(graphics.__boundsHeight, super.__getNaturalHeight());
	}
}
