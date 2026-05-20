package openfl.display;

import openfl.geom.Rectangle;

class Shape extends DisplayObject {
	public var graphics(default, null):Graphics;

	public function new() {
		super();
		graphics = new Graphics();
	}

	override public function __render(g2:kha.graphics2.Graphics, offsetX:Float, offsetY:Float):Void {
		if (!__beginRender(g2, offsetX, offsetY)) {
			return;
		}

		graphics.__render(g2, 0, 0);
		__endRender(g2);
	}

	@:allow(openfl.display)
	override function __getLocalBounds():Rectangle {
		return graphics.__getBounds();
	}
}
