package openfl.media;

class Sound {
	public var bytesLoaded(default, null):Int = 0;
	public var bytesTotal(default, null):Int = 0;
	public var id3(default, null):ID3Info;
	public var isBuffering(default, null):Bool = false;
	public var length(get, never):Float;
	public var url(default, null):String;

	var __sound:kha.Sound;

	public function new(sound:kha.Sound = null, url:String = null) {
		__sound = sound;
		this.url = url;
		id3 = new ID3Info();
	}

	public function close():Void {}

	public function load(stream:Dynamic, context:Dynamic = null):Void {}

	public function loadCompressedDataFromByteArray(bytes:Dynamic, bytesLength:Int, forcePlayAsMusic:Bool = false):Void {}

	public function loadPCMFromByteArray(bytes:Dynamic, samples:Int, format:String = "float", stereo:Bool = true, sampleRate:Float = 44100):Void {}

	public function play(startTime:Float = 0, loops:Int = 0, sndTransform:Dynamic = null):SoundChannel {
		if (__sound == null) {
			return new SoundChannel();
		}

		var channel = kha.audio1.Audio.play(__sound, loops > 0);
		if (channel != null && startTime > 0) {
			channel.position = startTime / 1000;
		}

		var result = new SoundChannel(channel);
		result.soundTransform = sndTransform;
		return result;
	}

	function get_length():Float {
		return __sound != null ? __sound.length * 1000 : 0;
	}
}
