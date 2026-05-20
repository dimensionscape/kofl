package openfl.display;

#if !flash
#if (haxe_ver >= 4.0) enum #else @:enum #end abstract BitmapDataChannel(Int) from Int to Int from UInt to UInt {
	public var ALPHA = 8;
	public var BLUE = 4;
	public var GREEN = 2;
	public var RED = 1;
}
#else
typedef BitmapDataChannel = flash.display.BitmapDataChannel;
#end
