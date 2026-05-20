package openfl.ui;

@:final class Mouse {
	public static var cursor:MouseCursor = MouseCursor.AUTO;
	public static var supportsCursor(default, null):Bool = true;
	public static var supportsNativeCursor(default, null):Bool = false;

	public static function hide():Void {}

	public static function registerCursor(name:String, cursor:Dynamic):Void {}

	public static function show():Void {}

	public static function unregisterCursor(name:String):Void {}
}
