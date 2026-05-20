package openfl.system;

@:final class Capabilities {
	public static var avHardwareDisable(default, null) = true;
	public static var cpuArchitecture(get, never):String;
	public static var hasAccessibility(default, null) = false;
	public static var hasAudio(default, null) = true;
	public static var hasAudioEncoder(default, null) = false;
	public static var hasEmbeddedVideo(default, null) = false;
	public static var hasIME(default, null) = false;
	public static var hasMP3(default, null) = true;
	public static var hasPrinting(default, null) = false;
	public static var hasScreenBroadcast(default, null) = false;
	public static var hasScreenPlayback(default, null) = false;
	public static var hasStreamingAudio(default, null) = true;
	public static var hasStreamingVideo(default, null) = false;
	public static var hasTLS(default, null) = true;
	public static var hasVideoEncoder(default, null) = false;
	public static var isDebugger(default, null) = #if debug true #else false #end;
	public static var language(default, null) = "en";
	public static var manufacturer(get, never):String;
	public static var os(get, never):String;
	public static var pixelAspectRatio(default, null):Float = 1.0;
	public static var playerType(default, null) = "Desktop";
	public static var screenColor(default, null) = "color";
	public static var screenDPI(default, null):Float = 96;
	public static var screenResolutionX(get, never):Float;
	public static var screenResolutionY(get, never):Float;
	public static var version(get, never):String;

	static function get_cpuArchitecture():String {
		#if cpp
		return "x86";
		#elseif js
		return "JavaScript";
		#else
		return "Unknown";
		#end
	}

	static function get_manufacturer():String {
		return "KOFL";
	}

	static function get_os():String {
		#if windows
		return "Windows";
		#elseif mac
		return "macOS";
		#elseif linux
		return "Linux";
		#elseif js
		return "HTML5";
		#else
		return "Unknown";
		#end
	}

	static function get_screenResolutionX():Float {
		var stage = openfl.Lib.get_stage();
		return stage != null ? stage.stageWidth : 0;
	}

	static function get_screenResolutionY():Float {
		var stage = openfl.Lib.get_stage();
		return stage != null ? stage.stageHeight : 0;
	}

	static function get_version():String {
		#if cpp
		return "KOFL 1,0,0,0";
		#elseif js
		return "KOFL HTML5 1,0,0,0";
		#else
		return "KOFL 0,0,0,0";
		#end
	}
}
