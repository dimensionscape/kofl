package openfl.media;

class SoundChannel {
	public var leftPeak(default, null):Float = 0;
	public var position(get, set):Float;
	public var rightPeak(default, null):Float = 0;
	public var soundTransform:Dynamic;

	var __channel:kha.audio1.AudioChannel;

	public function new(channel:kha.audio1.AudioChannel = null) {
		__channel = channel;
	}

	public function stop():Void {
		if (__channel != null) {
			__channel.stop();
		}
	}

	@:allow(openfl.media.SoundMixer)
	function __updateTransform():Void {}

	function get_position():Float {
		return __channel != null ? __channel.position * 1000 : 0;
	}

	function set_position(value:Float):Float {
		if (__channel != null) {
			__channel.position = value / 1000;
		}
		return value;
	}
}
