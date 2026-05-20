package openfl._internal.kha.display;

import kha.Color;
import openfl.events.UncaughtErrorEvent;
import openfl.events.UncaughtErrorEvents;

class Stage extends DisplayObjectContainer {
	public var backgroundColor:Color;
	public var stageWidth:Int;
	public var stageHeight:Int;
	public var __uncaughtErrorEvents(default, null):UncaughtErrorEvents;

	public function new(stageWidth:Int, stageHeight:Int, backgroundColor:Color) {
		super();
		this.stageWidth = stageWidth;
		this.stageHeight = stageHeight;
		this.backgroundColor = backgroundColor;
		__uncaughtErrorEvents = new UncaughtErrorEvents();
	}

	override function get_stage():openfl.display.Stage {
		return cast this;
	}

	override public function __render(g2:kha.graphics2.Graphics, offsetX:Float, offsetY:Float):Void {
		for (child in __children) {
			child.__render(g2, 0, 0);
		}
	}

	public function __handleError(error:Dynamic):Void {
		__uncaughtErrorEvents.dispatchEvent(new UncaughtErrorEvent(UncaughtErrorEvent.UNCAUGHT_ERROR, true, true, error));
	}
}
