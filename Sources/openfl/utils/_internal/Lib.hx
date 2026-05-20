package openfl.utils._internal;

import haxe.ds.ObjectMap;
import haxe.PosInfos;
import openfl.utils._internal.Log;
#if !openfl_unit_testing
import openfl.display.Application;
#end
import openfl.display.MovieClip;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@SuppressWarnings("checkstyle:FieldDocComment")
class Lib
{
	public static var application:#if !openfl_unit_testing Application #else Dynamic #end;
	public static var current:MovieClip #if flash = flash.Lib.current #end;
	public static var __registeredClassAliases:Map<String, Class<Dynamic>> = new Map();
	public static var __registeredClasses:ObjectMap<Dynamic, String> = new ObjectMap();
	@:noCompletion private static var __sentWarnings:Map<String, Bool> = new Map();

	public static function getAliasByClass(classObject:Class<Dynamic>):String
	{
		if (classObject == null || !__registeredClasses.exists(classObject))
		{
			return null;
		}

		return __registeredClasses.get(classObject);
	}

	public static function getClassByAlias(aliasName:String):Class<Dynamic>
	{
		if (aliasName == null || !__registeredClassAliases.exists(aliasName))
		{
			return null;
		}

		return __registeredClassAliases.get(aliasName);
	}

	@SuppressWarnings("checkstyle:NullableParameter")
	public static function notImplemented(?posInfo:PosInfos):Void
	{
		var api = posInfo.className + "." + posInfo.methodName;

		if (!__sentWarnings.exists(api))
		{
			__sentWarnings.set(api, true);

			Log.warn(posInfo.methodName + " is not implemented", posInfo);
		}
	}

	public static function registerClassAlias(aliasName:String, classObject:Class<Dynamic>):Void
	{
		__registeredClassAliases.set(aliasName, classObject);
		__registeredClasses.set(classObject, aliasName);
	}
}
