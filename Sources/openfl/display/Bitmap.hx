package openfl.display;

import openfl.geom.Rectangle;

class Bitmap extends DisplayObject {
	public var bitmapData(get, set):BitmapData;
	public var pixelSnapping:PixelSnapping;
	public var smoothing:Bool;

	var __bitmapData:BitmapData;

	public function new(bitmapData:BitmapData = null, pixelSnapping:PixelSnapping = null, smoothing:Bool = false) {
		super();
		this.pixelSnapping = pixelSnapping == null ? PixelSnapping.AUTO : pixelSnapping;
		this.smoothing = smoothing;
		this.bitmapData = bitmapData;
	}

	override public function __render(g2:kha.graphics2.Graphics, offsetX:Float, offsetY:Float):Void {
		if (!__beginRender(g2, offsetX, offsetY)) {
			return;
		}

		if (__bitmapData != null) {
			if (__bitmapData.__image != null) {
				g2.drawImage(__bitmapData.__image, 0, 0);
			} else {
				__bitmapData.__forEachPixel(function(x:Int, y:Int, color:Int) {
					var alpha = (color >> 24) & 0xFF;
					if (alpha == 0) {
						return;
					}

					g2.color = kha.Color.fromBytes((color >> 16) & 0xFF, (color >> 8) & 0xFF, color & 0xFF, alpha);
					g2.fillRect(x, y, 1, 1);
				});
				g2.color = kha.Color.White;
			}
		}

		__endRender(g2);
	}

	override public function __getNaturalWidth():Float {
		return __bitmapData != null ? __bitmapData.width : 0;
	}

	override public function __getNaturalHeight():Float {
		return __bitmapData != null ? __bitmapData.height : 0;
	}

	@:allow(openfl.display)
	override function __getLocalBounds():Rectangle {
		return new Rectangle(0, 0, __getNaturalWidth(), __getNaturalHeight());
	}

	function get_bitmapData():BitmapData {
		return __bitmapData;
	}

	function set_bitmapData(value:BitmapData):BitmapData {
		__bitmapData = value;
		if (value != null) {
			smoothing = false;
		}
		return value;
	}
}
