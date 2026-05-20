package openfl.filters;

#if !flash
@:final class ColorMatrixFilter extends BitmapFilter {
	public var matrix(get, set):Array<Float>;

	var __matrix:Array<Float>;

	public function new(matrix:Array<Float> = null) {
		super();
		this.matrix = matrix;
	}

	override public function clone():BitmapFilter {
		return new ColorMatrixFilter(__matrix);
	}

	function get_matrix():Array<Float> {
		return __matrix.copy();
	}

	function set_matrix(value:Array<Float>):Array<Float> {
		if (value == null) {
			value = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
		}

		__matrix = value.copy();
		return __matrix.copy();
	}
}
#else
typedef ColorMatrixFilter = flash.filters.ColorMatrixFilter;
#end
