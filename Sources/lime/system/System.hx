package lime.system;

class System {
	public static function exit(code:Int):Void {
		#if sys
		Sys.exit(code);
		#end
	}
}
