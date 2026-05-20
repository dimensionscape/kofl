package openfl;

import kha.Color;
import haxe.ds.ObjectMap;
import haxe.Timer;
import openfl._internal.kha.ApplicationBackend;
import openfl._internal.kha.ApplicationBackend.ApplicationConfig;
import openfl.display.Application;
import openfl.display.DisplayObjectContainer;
import openfl.display.LoaderInfo;
import openfl.display.MovieClip;
import openfl.display.Stage;
import openfl.errors.Error;
import openfl.errors.TypeError;
import openfl.utils._internal.Lib as InternalLib;

class Lib {
	public static var application:Application;
	public static var current(get, set):DisplayObjectContainer;
	static var __lastTimerID:UInt = 0;
	static var __timers:Map<UInt, Timer> = new Map();
	static var __registeredClassAliases:Map<String, Class<Dynamic>> = new Map();
	static var __registeredClasses:ObjectMap<Dynamic, String> = new ObjectMap();
	@:allow(openfl._internal.kha.display.DisplayObject)
	@:allow(openfl.display.Application)
	static var __constructionStage:Stage;
	@:allow(openfl.display.Application)
	static var __constructionCurrent:DisplayObjectContainer;
	static var __current:DisplayObjectContainer;

	public static function start(config:{
		var title:String;
		var width:Int;
		var height:Int;
		var backgroundColor:Int;
	}, createRoot:Void->DisplayObjectContainer):Void {
		var app = new Application();
		application = app;
		app.create(config, createRoot);
	}

	@:allow(openfl.display)
	static function __startWithApplication(instance:Application, config:{
		var title:String;
		var width:Int;
		var height:Int;
		var backgroundColor:Int;
	}, setup:ApplicationBackend->Void):Void {
		var appConfig:ApplicationConfig = {
			title: config.title,
			width: config.width,
			height: config.height,
			backgroundColor: Color.fromBytes((config.backgroundColor >> 16) & 0xFF, (config.backgroundColor >> 8) & 0xFF, config.backgroundColor & 0xFF)
		};

		ApplicationBackend.boot(appConfig, function(app:ApplicationBackend) {
			application = instance;
			setup(app);
		});
	}

	public static function as<T>(v:Dynamic, c:Class<T>):Null<T> {
		return Std.isOfType(v, c) ? v : null;
	}

	public static function attach(name:String):MovieClip {
		return new MovieClip();
	}

	public static function clearInterval(id:UInt):Void {
		clearTimeout(id);
	}

	public static function clearTimeout(id:UInt):Void {
		if (__timers.exists(id)) {
			__timers[id].stop();
			__timers.remove(id);
		}
	}

	public static function decodeURIComponent(value:String):String {
		return StringTools.urlDecode(value);
	}

	public static function encodeURIComponent(value:String):String {
		return StringTools.urlEncode(value);
	}

	public static function getDefinitionByName(name:String):Class<Dynamic> {
		if (name == null) {
			return null;
		}
		return Type.resolveClass(StringTools.replace(name, "::", "."));
	}

	public static function getClassByAlias(aliasName:String):Class<Dynamic> {
		if (aliasName == null || !__registeredClassAliases.exists(aliasName)) {
			return null;
		}

		return __registeredClassAliases.get(aliasName);
	}

	public static function getQualifiedClassName(value:Dynamic):String {
		if (value == null) {
			return null;
		}

		var ref = (value is Class) ? value : Type.getClass(value);
		if (ref == null) {
			if ((value is Bool) || value == Bool) return "Bool";
			if ((value is Int) || value == Int) return "Int";
			if ((value is Float) || value == Float) return "Float";
			return null;
		}

		return Type.getClassName(ref);
	}

	public static function getQualifiedSuperclassName(value:Dynamic):String {
		if (value == null) {
			return null;
		}

		var ref = (value is Class) ? value : Type.getClass(value);
		if (ref == null) {
			return null;
		}

		if (ref == openfl.display.DisplayObject) {
			return "openfl.events.EventDispatcher";
		}

		var parent = Type.getSuperClass(ref);
		if (parent == null) {
			return null;
		}

		var parentName = Type.getClassName(parent);
		return switch (parentName) {
			case "openfl._internal.kha.display.DisplayObject": "openfl.events.EventDispatcher";
			default: parentName;
		}
	}

	public static function isXMLName(name:String):Bool {
		if (name == null || name.length == 0) {
			return false;
		}

		return ~/^[A-Za-z_][:A-Za-z0-9._-]*$/.match(name);
	}

	public static function registerClassAlias(aliasName:String, classObject:Class<Dynamic>):Void {
		if (classObject == null) {
			throw new TypeError("Parameter classObject must be non-null");
		}

		if (aliasName == null) {
			throw new TypeError("Parameter aliasName must be non-null");
		}

		__registeredClassAliases.set(aliasName, classObject);
		__registeredClasses.set(classObject, aliasName);
		InternalLib.registerClassAlias(aliasName, classObject);
	}

	public static function getTimer():Int {
		return Std.int(haxe.Timer.stamp() * 1000);
	}

	public static function setInterval(closure:Dynamic, delay:Int, args:Array<Dynamic> = null):UInt {
		var id = ++__lastTimerID;
		var timer = new Timer(delay);
		timer.run = function() {
			if (args == null) {
				Reflect.callMethod(null, closure, []);
			} else {
				Reflect.callMethod(null, closure, args);
			}
		};
		__timers.set(id, timer);
		return id;
	}

	public static function setTimeout(closure:Dynamic, delay:Int, args:Array<Dynamic> = null):UInt {
		var id = ++__lastTimerID;
		Timer.delay(function() {
			if (args == null) {
				Reflect.callMethod(null, closure, []);
			} else {
				Reflect.callMethod(null, closure, args);
			}
			__timers.remove(id);
		}, delay);
		return id;
	}

	public static function get_stage():Stage {
		return application != null ? application.stage : null;
	}

	static function get_current():DisplayObjectContainer {
		if (__current != null) {
			return __current;
		}

		if (__constructionCurrent != null) {
			return __constructionCurrent;
		}

		return null;
	}

	static function set_current(value:DisplayObjectContainer):DisplayObjectContainer {
		__current = value;
		return value;
	}

	@:noCompletion
	public static function __getAliasByClass(classObject:Class<Dynamic>):String {
		if (classObject == null || !__registeredClasses.exists(classObject)) {
			return null;
		}

		return __registeredClasses.get(classObject);
	}
}
