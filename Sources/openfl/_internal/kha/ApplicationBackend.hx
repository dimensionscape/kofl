package openfl._internal.kha;

import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.input.Keyboard;
import kha.input.KeyCode;
import kha.input.Mouse;
import openfl._internal.kha.debug.FrameCapture;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TextEvent;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.text.TextFieldType;

typedef ApplicationConfig = {
	var title:String;
	var width:Int;
	var height:Int;
	var backgroundColor:Color;
}

class ApplicationBackend {
	public var config(default, null):ApplicationConfig;
	public var stage(default, null):Stage;
	public dynamic function onReady():Void {}
	public dynamic function onUpdate(deltaTime:Float):Void {}

	var __shiftDown = false;
	var __lastTickTime = 0.0;

	public function new(config:ApplicationConfig) {
		this.config = config;
		stage = new Stage(config.width, config.height, config.backgroundColor);
		stage.application = this;
	}

	public static function boot(config:ApplicationConfig, setup:ApplicationBackend->Void):Void {
		__keepNativeStackTrace();

		#if sys
		var programPath = Sys.programPath();
		var windowsSlash = programPath.lastIndexOf("\\");
		var unixSlash = programPath.lastIndexOf("/");
		var slash = windowsSlash > unixSlash ? windowsSlash : unixSlash;
		if (slash > 0) {
			Sys.setCwd(programPath.substr(0, slash));
		}
		#end

		System.start({
			title: config.title,
			width: config.width,
			height: config.height
		}, function(_) {
			__trace('Application.boot before Assets.loadEverything');
			Assets.loadEverything(function() {
				__trace('Application.boot loadEverything callback images=' + Reflect.fields(kha.Assets.images).join(","));
				__trace('Application.boot loadEverything image assets_1x1 null=' + (kha.Assets.images.get("assets_1x1") == null));
				var app = new ApplicationBackend(config);
				setup(app);
				app.bindInput();
				app.onReady();
				app.__lastTickTime = Scheduler.time();
				Scheduler.addFrameTask(function() {
					app.frame();
				}, 0);
				System.notifyOnFrames(function(framebuffers:Array<Framebuffer>) {
					app.render(framebuffers);
				});
			}, null, null, function(error) {
				__trace('Application.boot loadEverything failure=' + Std.string(error));
			});
		});
	}

	function tick(deltaTime:Float):Void {
		onUpdate(deltaTime);
		stage.__broadcastEnterFrame();
		stage.__update(deltaTime);
	}

	function frame():Void {
		var now = Scheduler.time();
		var deltaTime = now - __lastTickTime;
		if (deltaTime < 0) {
			deltaTime = 0;
		} else if (deltaTime > 0.25) {
			deltaTime = 0.25;
		}
		__lastTickTime = now;
		tick(deltaTime);
	}

	function bindInput():Void {
		var mouse = Mouse.get();
		if (mouse != null) {
			mouse.notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
		}

		var keyboard = Keyboard.get();
		if (keyboard != null) {
			keyboard.notify(onKeyDown, onKeyUp, onKeyPress);
		}
	}

	function render(framebuffers:Array<Framebuffer>):Void {
		if (framebuffers == null || framebuffers.length == 0) {
			return;
		}

		var framebuffer = framebuffers[0];
		var g2 = framebuffer.g2;
		g2.begin(true, stage.backgroundColor);
		stage.__render(g2, 0, 0);
		g2.end();
		FrameCapture.captureIfRequested(stage, framebuffer.width, framebuffer.height, stage.backgroundColor);
	}

	function onMouseDown(button:Int, x:Int, y:Int):Void {
		stage.__mouseX = x;
		stage.__mouseY = y;
		var target = stage.__resolveInteractiveTarget(x, y);
		var local = target != null ? target.globalToLocal(new openfl.geom.Point(x, y)) : new openfl.geom.Point(x, y);
		if (target != null) {
			stage.focus = target;
			var event = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, local.x, local.y, null, false, false, false, button == 0);
			event.stageX = x;
			event.stageY = y;
			target.dispatchEvent(event);
		} else {
			stage.focus = null;
			var event = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, x, y, null, false, false, false, button == 0);
			event.stageX = x;
			event.stageY = y;
			stage.dispatchEvent(event);
		}
	}

	function onMouseUp(button:Int, x:Int, y:Int):Void {
		stage.__mouseX = x;
		stage.__mouseY = y;
		var target = stage.__resolveInteractiveTarget(x, y);
		var local = target != null ? target.globalToLocal(new openfl.geom.Point(x, y)) : new openfl.geom.Point(x, y);
		if (target != null) {
			var mouseUp = new MouseEvent(MouseEvent.MOUSE_UP, true, false, local.x, local.y, null, false, false, false, button == 0);
			mouseUp.stageX = x;
			mouseUp.stageY = y;
			target.dispatchEvent(mouseUp);
			var click = new MouseEvent(MouseEvent.CLICK, true, false, local.x, local.y);
			click.stageX = x;
			click.stageY = y;
			target.dispatchEvent(click);
		} else {
			var event = new MouseEvent(MouseEvent.MOUSE_UP, true, false, x, y, null, false, false, false, button == 0);
			event.stageX = x;
			event.stageY = y;
			stage.dispatchEvent(event);
		}
	}

	function onMouseMove(x:Int, y:Int, movementX:Int, movementY:Int):Void {
		stage.__mouseX = x;
		stage.__mouseY = y;
		var target = stage.__resolveInteractiveTarget(x, y);
		var local = target != null ? target.globalToLocal(new openfl.geom.Point(x, y)) : new openfl.geom.Point(x, y);
		if (target != null) {
			var event = new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, local.x, local.y);
			event.stageX = x;
			event.stageY = y;
			target.dispatchEvent(event);
		} else {
			var event = new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, x, y);
			event.stageX = x;
			event.stageY = y;
			stage.dispatchEvent(event);
		}
	}

	function onMouseWheel(delta:Int):Void {
		if (stage.focus != null) {
			stage.focus.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_WHEEL, true, false, 0, 0, null, false, false, false, false, delta));
		} else {
			stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_WHEEL, true, false, 0, 0, null, false, false, false, false, delta));
		}
	}

	function onKeyDown(key:Dynamic):Void {
		var keyCode:KeyCode = cast key;
		if (keyCode == KeyCode.Shift) {
			__shiftDown = true;
		}

		if (stage.focus != null) {
			stage.focus.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, cast key));

			if (Std.isOfType(stage.focus, openfl.text.TextField) && cast(stage.focus, openfl.text.TextField).type == openfl.text.TextFieldType.INPUT) {
				var textField:openfl.text.TextField = cast stage.focus;
				#if cpp
				__applyNativeTextInput(textField, keyCode);
				#else
				if (cast key == 8 && textField.text.length > 0) {
					textField.text = textField.text.substr(0, textField.text.length - 1);
				}
				#end
			}
		} else {
			stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, cast key));
		}
	}

	function onKeyUp(key:Dynamic):Void {
		var keyCode:KeyCode = cast key;
		if (keyCode == KeyCode.Shift) {
			__shiftDown = false;
		}

		if (stage.focus != null) {
			stage.focus.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, cast key));
		} else {
			stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, cast key));
		}
	}

	function onKeyPress(char:String):Void {
		if (stage.focus != null) {
			if (#if !cpp Std.isOfType(stage.focus, openfl.text.TextField) && cast(stage.focus, openfl.text.TextField).type == openfl.text.TextFieldType.INPUT && char != null
				&& char != String.fromCharCode(8) && char != String.fromCharCode(13) #else false #end) {
				var textField:openfl.text.TextField = cast stage.focus;
				textField.appendText(char);
			}
			stage.focus.dispatchEvent(new TextEvent(TextEvent.TEXT_INPUT, true, true, char));
		} else {
			stage.dispatchEvent(new TextEvent(TextEvent.TEXT_INPUT, true, true, char));
		}
	}

	#if cpp
	static function __keepNativeStackTrace():Void {
		var keep = haxe.NativeStackTrace.toHaxe;
		if (keep == null) {}
	}

	function __applyNativeTextInput(textField:TextField, keyCode:KeyCode):Void {
		if (keyCode == KeyCode.Backspace) {
			if (textField.text.length > 0) {
				textField.text = textField.text.substr(0, textField.text.length - 1);
			}
			return;
		}

		var value = __keyCodeToChar(keyCode);
		if (value != null) {
			textField.appendText(value);
			textField.dispatchEvent(new TextEvent(TextEvent.TEXT_INPUT, true, true, value));
		}
	}

	function __keyCodeToChar(keyCode:KeyCode):String {
		var code:Int = cast keyCode;
		var a:Int = cast KeyCode.A;
		var z:Int = cast KeyCode.Z;
		var zero:Int = cast KeyCode.Zero;
		var nine:Int = cast KeyCode.Nine;

		if (code >= a && code <= z) {
			var base = __shiftDown ? "A".code : "a".code;
			return String.fromCharCode(base + (code - a));
		}

		if (code >= zero && code <= nine) {
			var shifted = [")", "!", "@", "#", "$", "%", "^", "&", "*", "("];
			return __shiftDown ? shifted[code - zero] : String.fromCharCode("0".code + (code - zero));
		}

		return switch (keyCode) {
			case Space: " ";
			case Comma: __shiftDown ? "<" : ",";
			case Period: __shiftDown ? ">" : ".";
			case Slash: __shiftDown ? "?" : "/";
			case Semicolon: __shiftDown ? ":" : ";";
			case Quote: __shiftDown ? "\"" : "'";
			case OpenBracket: __shiftDown ? "{" : "[";
			case CloseBracket: __shiftDown ? "}" : "]";
			case BackSlash: __shiftDown ? "|" : "\\";
			case HyphenMinus: __shiftDown ? "_" : "-";
			case Equals: __shiftDown ? "+" : "=";
			case BackQuote: __shiftDown ? "~" : "`";
			case Tab: "\t";
			default: null;
		}
	}
	#end

	#if !cpp
	static inline function __keepNativeStackTrace():Void {}
	#end

	static function __trace(message:String):Void {
		#if sys
		var path = Sys.getEnv("KOFL_TIMER_TRACE_PATH");
		if (path == null || path == "") {
			return;
		}

		try {
			var output = sys.io.File.append(path, false);
			output.writeString(message + "\n");
			output.close();
		} catch (_:Dynamic) {}
		#end
	}
}
