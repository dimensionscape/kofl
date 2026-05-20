package openfl.display;

class MovieClip extends Sprite {
	public var currentFrame(default, null):Int = 1;
	public var currentFrameLabel(default, null):String = null;
	public var currentLabel(default, null):String = null;
	public var currentLabels(default, null):Array<FrameLabel> = [];
	public var enabled:Bool = true;
	public var framesLoaded(default, null):Int = 1;
	public var totalFrames(default, null):Int = 1;

	var __isPlaying = false;

	public function new() {
		super();
	}

	public function gotoAndPlay(frame:Dynamic, scene:String = null):Void {
		__isPlaying = true;
		__setFrame(frame);
	}

	public function gotoAndStop(frame:Dynamic, scene:String = null):Void {
		__isPlaying = false;
		__setFrame(frame);
	}

	public function nextFrame():Void {
		currentFrame = Std.int(Math.min(totalFrames, currentFrame + 1));
	}

	public function play():Void {
		__isPlaying = true;
	}

	public function prevFrame():Void {
		currentFrame = Std.int(Math.max(1, currentFrame - 1));
	}

	public function stop():Void {
		__isPlaying = false;
	}

	function __setFrame(frame:Dynamic):Void {
		if (Std.isOfType(frame, Int)) {
			currentFrame = Std.int(Math.max(1, Math.min(totalFrames, cast frame)));
			return;
		}

		if (frame != null) {
			currentFrameLabel = Std.string(frame);
			currentLabel = currentFrameLabel;
		}
	}
}
