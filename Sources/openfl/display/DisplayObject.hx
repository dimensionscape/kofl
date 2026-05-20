package openfl.display;

import openfl.display.BlendMode;
import openfl.filters.BitmapFilter;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.Transform;

class DisplayObject extends openfl._internal.kha.display.DisplayObject {
	static var __instanceCount = 0;

	public var blendMode(get, set):BlendMode;
	public var cacheAsBitmap(get, set):Bool;
	public var filters(get, set):Array<BitmapFilter>;
	public var loaderInfo(get, never):Dynamic;
	public var mask(get, set):DisplayObject;
	public var mouseX(get, never):Float;
	public var mouseY(get, never):Float;
	public var opaqueBackground:Null<Int>;
	public var root(get, never):DisplayObject;
	public var scale9Grid:Rectangle;
	public var scrollRect:Rectangle;
	public var transform(get, set):Transform;

	var __blendMode:BlendMode = BlendMode.NORMAL;
	var __cacheAsBitmap = false;
	var __filters:Array<BitmapFilter> = [];
	var __mask:DisplayObject;
	var __maskTarget:DisplayObject;
	var __transformObject:Transform;

	public function new() {
		super();
		name = "instance" + __instanceCount++;
	}

	public function getBounds(targetCoordinateSpace:DisplayObject):Rectangle {
		var localBounds = __getLocalBounds();
		if (targetCoordinateSpace == this || targetCoordinateSpace == null) {
			return localBounds;
		}

		var world = __getWorldMatrix();
		var target = targetCoordinateSpace.__getWorldMatrix().clone();
		target.invert();

		var result = new Rectangle();
		__transformRect(localBounds, world, result);
		__transformRect(result, target, result);
		return result;
	}

	public function getRect(targetCoordinateSpace:DisplayObject):Rectangle {
		return getBounds(targetCoordinateSpace);
	}

	public function globalToLocal(pos:Point):Point {
		var matrix = __getWorldMatrix().clone();
		matrix.invert();
		return matrix.transformPoint(pos);
	}

	public function hitTestObject(obj:DisplayObject):Bool {
		return getBounds(null).intersects(obj.getBounds(null));
	}

	public function hitTestPoint(x:Float, y:Float, shapeFlag:Bool = false):Bool {
		var bounds = getBounds(null);
		if (shapeFlag) {
			return x > bounds.x && y > bounds.y && x < bounds.right && y < bounds.bottom;
		}
		return bounds.contains(x, y);
	}

	public function localToGlobal(point:Point):Point {
		return __getWorldMatrix().transformPoint(point);
	}

	@:allow(openfl.display)
	function __getLocalBounds():Rectangle {
		return new Rectangle();
	}

	@:allow(openfl.display)
	@:allow(openfl.geom)
	function __getLocalMatrix():Matrix {
		var radians = rotation * (Math.PI / 180);
		var cos = Math.cos(radians);
		var sin = Math.sin(radians);
		return new Matrix(cos * scaleX, sin * scaleX, -sin * scaleY, cos * scaleY, x, y);
	}

	@:allow(openfl.display)
	function __getWorldMatrix():Matrix {
		var matrices:Array<Matrix> = [];
		var current:openfl._internal.kha.display.DisplayObject = this;

		while (current != null) {
			if (Std.isOfType(current, DisplayObject)) {
				matrices.push(cast(current, DisplayObject).__getLocalMatrix());
			} else {
				var radians = current.rotation * (Math.PI / 180);
				var cos = Math.cos(radians);
				var sin = Math.sin(radians);
				matrices.push(new Matrix(cos * current.scaleX, sin * current.scaleX, -sin * current.scaleY, cos * current.scaleY, current.x, current.y));
			}
			current = current.parent;
		}

		var result = new Matrix();
		for (i in 0...matrices.length) {
			result.concat(matrices[matrices.length - 1 - i]);
		}
		return result;
	}

	function __transformRect(source:Rectangle, matrix:Matrix, output:Rectangle):Void {
		var p1 = matrix.transformPoint(new Point(source.x, source.y));
		var p2 = matrix.transformPoint(new Point(source.right, source.y));
		var p3 = matrix.transformPoint(new Point(source.right, source.bottom));
		var p4 = matrix.transformPoint(new Point(source.x, source.bottom));

		var minX = Math.min(Math.min(p1.x, p2.x), Math.min(p3.x, p4.x));
		var maxX = Math.max(Math.max(p1.x, p2.x), Math.max(p3.x, p4.x));
		var minY = Math.min(Math.min(p1.y, p2.y), Math.min(p3.y, p4.y));
		var maxY = Math.max(Math.max(p1.y, p2.y), Math.max(p3.y, p4.y));
		output.setTo(__normalizeZero(minX), __normalizeZero(minY), __normalizeZero(maxX - minX), __normalizeZero(maxY - minY));
	}

	override public function __getNaturalWidth():Float {
		return __getLocalBounds().width;
	}

	override public function __getNaturalHeight():Float {
		return __getLocalBounds().height;
	}

	@:noCompletion public function __stopAllMovieClips():Void {}

	function get_blendMode():BlendMode {
		return __blendMode;
	}

	function set_blendMode(value:BlendMode):BlendMode {
		__blendMode = value == null ? BlendMode.NORMAL : value;
		return __blendMode;
	}

	function get_cacheAsBitmap():Bool {
		return __filters.length > 0 ? true : __cacheAsBitmap;
	}

	function set_cacheAsBitmap(value:Bool):Bool {
		__cacheAsBitmap = value;
		return value;
	}

	function get_filters():Array<BitmapFilter> {
		return __filters.copy();
	}

	function set_filters(value:Array<BitmapFilter>):Array<BitmapFilter> {
		__filters = [];
		if (value != null) {
			for (filter in value) {
				__filters.push(filter.clone());
			}
		}
		return value;
	}

	function get_loaderInfo():Dynamic {
		return stage != null && openfl.Lib.current != null ? openfl.Lib.current.__loaderInfo : null;
	}

	function get_mask():DisplayObject {
		return __mask;
	}

	function set_mask(value:DisplayObject):DisplayObject {
		if (value == __mask) {
			return value;
		}

		if (value != null && value.__maskTarget != null && value.__maskTarget != this) {
			value.__maskTarget.mask = null;
		}

		if (__mask != null) {
			__mask.__maskTarget = null;
		}

		__mask = value;
		if (value != null) {
			value.__maskTarget = this;
		}
		return value;
	}

	function get_mouseX():Float {
		var currentStage = cast stage;
		return currentStage != null ? globalToLocal(new Point(currentStage.__mouseX, currentStage.__mouseY)).x : 0;
	}

	function get_mouseY():Float {
		var currentStage = cast stage;
		return currentStage != null ? globalToLocal(new Point(currentStage.__mouseX, currentStage.__mouseY)).y : 0;
	}

	function get_root():DisplayObject {
		return stage != null ? cast openfl.Lib.current : null;
	}

	function get_transform():Transform {
		if (__transformObject == null) {
			__transformObject = new Transform(this);
		}
		return __transformObject;
	}

	function set_transform(value:Transform):Transform {
		if (value == null) {
			return get_transform();
		}

		var matrix = value.matrix;
		x = matrix.tx;
		y = matrix.ty;
		scaleX = Math.sqrt(matrix.a * matrix.a + matrix.b * matrix.b);
		scaleY = Math.sqrt(matrix.c * matrix.c + matrix.d * matrix.d);
		rotation = Math.atan2(matrix.b, matrix.a) * (180 / Math.PI);
		get_transform().colorTransform = value.colorTransform;
		return get_transform();
	}

	static function __normalizeZero(value:Float):Float {
		return Math.abs(value) < 1e-10 ? 0.0 : value;
	}
}
