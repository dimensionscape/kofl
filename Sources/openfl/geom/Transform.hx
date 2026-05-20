package openfl.geom;

class Transform {
	public var colorTransform(get, set):ColorTransform;
	public var concatenatedColorTransform(get, never):ColorTransform;
	public var concatenatedMatrix(get, never):Matrix;
	public var matrix(get, set):Matrix;
	public var pixelBounds(get, never):Rectangle;

	var displayObject:Dynamic;
	var __colorTransform:ColorTransform;

	public function new(displayObject:Dynamic) {
		this.displayObject = displayObject;
		__colorTransform = new ColorTransform();
	}

	function get_colorTransform():ColorTransform {
		return __colorTransform;
	}

	function set_colorTransform(value:ColorTransform):ColorTransform {
		if (value != null) {
			__colorTransform = value;
		}
		return __colorTransform;
	}

	function get_concatenatedColorTransform():ColorTransform {
		return new ColorTransform(
			__colorTransform.redMultiplier,
			__colorTransform.greenMultiplier,
			__colorTransform.blueMultiplier,
			__colorTransform.alphaMultiplier,
			__colorTransform.redOffset,
			__colorTransform.greenOffset,
			__colorTransform.blueOffset,
			__colorTransform.alphaOffset
		);
	}

	function get_concatenatedMatrix():Matrix {
		return displayObject != null ? displayObject.__getWorldMatrix() : null;
	}

	function get_matrix():Matrix {
		return displayObject.__getLocalMatrix();
	}

	function set_matrix(value:Matrix):Matrix {
		if (value == null) {
			return get_matrix();
		}

		displayObject.x = value.tx;
		displayObject.y = value.ty;
		displayObject.scaleX = Math.sqrt(value.a * value.a + value.b * value.b);
		displayObject.scaleY = Math.sqrt(value.c * value.c + value.d * value.d);
		displayObject.rotation = Math.atan2(value.b, value.a) * (180 / Math.PI);
		return value;
	}

	function get_pixelBounds():Rectangle {
		if (displayObject == null) {
			return new Rectangle();
		}

		var stage = displayObject.stage;
		return displayObject.getBounds(stage != null ? stage : displayObject);
	}
}
