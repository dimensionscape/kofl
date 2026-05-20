package openfl.utils;

import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;

class Assets {
	static var __bitmapDataCache:Map<String, BitmapData> = new Map();
	static var __fontCache:Map<String, Font> = new Map();
	static var __soundCache:Map<String, Sound> = new Map();
	static var __khaFontByKey:Map<String, kha.Font> = new Map();

	public static function exists(id:String, type:Dynamic = null):Bool {
		return __findAssetName(kha.Assets.images, id, true) != null
			|| __findAssetName(kha.Assets.fonts, id, true) != null
			|| __findAssetName(kha.Assets.sounds, id, true) != null
			|| __findAssetName(kha.Assets.blobs, id, false) != null;
	}

	public static function getBitmapData(id:String, useCache:Bool = true):BitmapData {
		var assetName = __findAssetName(kha.Assets.images, id, true);
		__trace('Assets.getBitmapData id=' + id + ' assetName=' + assetName + ' useCache=' + useCache);
		if (assetName == null) {
			return null;
		}

		if (useCache && __bitmapDataCache.exists(assetName)) {
			__trace('Assets.getBitmapData cache-hit assetName=' + assetName);
			return __bitmapDataCache.get(assetName).clone();
		}

		var image = kha.Assets.images.get(assetName);
		__trace('Assets.getBitmapData image-null=' + (image == null) + ' assetName=' + assetName);
		if (image == null) {
			return null;
		}

		var bitmapData = BitmapData.__fromKhaImage(image, assetName);
		if (useCache) {
			__bitmapDataCache.set(assetName, bitmapData.clone());
		}
		return bitmapData;
	}

	public static function getFont(id:String, useCache:Bool = true):Font {
		var assetName = __findAssetName(kha.Assets.fonts, id, true);
		if (assetName == null) {
			return new Font();
		}

		if (useCache && __fontCache.exists(assetName)) {
			return __fontCache.get(assetName);
		}

		var khaFont = kha.Assets.fonts.get(assetName);
		if (khaFont == null) {
			return new Font();
		}

		var font = Font.__fromAsset(assetName, khaFont);
		__khaFontByKey.set(__normalizeFontKey(assetName), khaFont);
		__khaFontByKey.set(__normalizeFontKey(font.fontName), khaFont);

		if (useCache) {
			__fontCache.set(assetName, font);
		}

		return font;
	}

	public static function getSound(id:String, useCache:Bool = true):Sound {
		var assetName = __findAssetName(kha.Assets.sounds, id, true);
		if (assetName == null) {
			return new Sound();
		}

		if (useCache && __soundCache.exists(assetName)) {
			return __soundCache.get(assetName);
		}

		var khaSound = kha.Assets.sounds.get(assetName);
		var sound = new Sound(khaSound, id);
		if (useCache) {
			__soundCache.set(assetName, sound);
		}
		return sound;
	}

	public static function unloadLibrary(id:String):Void {
		if (id == null || id == "") {
			return;
		}

		__bitmapDataCache.remove(id);
		__fontCache.remove(id);
		__soundCache.remove(id);
		__khaFontByKey.remove(__normalizeFontKey(id));
	}

	@:allow(openfl.text.TextField)
	static function __getFontByName(name:String):kha.Font {
		if (name == null || name == "") {
			var defaultFont = kha.Assets.fonts != null ? kha.Assets.fonts.get("default_font") : null;
			return defaultFont;
		}

		var key = __normalizeFontKey(name);
		if (__khaFontByKey.exists(key)) {
			return __khaFontByKey.get(key);
		}

		var assetName = __findAssetName(kha.Assets.fonts, name, true);
		if (assetName != null) {
			var font = kha.Assets.fonts.get(assetName);
			if (font != null) {
				__khaFontByKey.set(key, font);
				__khaFontByKey.set(__normalizeFontKey(assetName), font);
				return font;
			}
		}

		return kha.Assets.fonts != null ? kha.Assets.fonts.get("default_font") : null;
	}

	static function __findAssetName(list:Dynamic, id:String, stripExtension:Bool):String {
		if (id == null || list == null) {
			__trace('__findAssetName early-null id=' + id + ' listNull=' + (list == null));
			return null;
		}

		var candidates = [id, StringTools.replace(id, "\\", "/")];
		if (stripExtension) {
			var stripped = __stripExtension(id);
			candidates.push(stripped);
			candidates.push(StringTools.replace(stripped, "\\", "/"));
		}

		for (candidate in candidates) {
			if (Reflect.hasField(list, candidate + "Description")) {
				__trace('__findAssetName direct-hit id=' + id + ' candidate=' + candidate);
				return candidate;
			}
		}

		var wantedPath = __normalizePathKey(id, stripExtension);
		var wantedFlat = __normalizeFontKey(id);
		for (field in Reflect.fields(list)) {
			if (!StringTools.endsWith(field, "Description")) {
				continue;
			}

			var name = field.substr(0, field.length - "Description".length);
			if (__normalizePathKey(name, stripExtension) == wantedPath || __normalizeFontKey(name) == wantedFlat) {
				__trace('__findAssetName normalized-hit id=' + id + ' field=' + field + ' name=' + name + ' wantedPath=' + wantedPath + ' wantedFlat=' + wantedFlat);
				return name;
			}
		}

		__trace('__findAssetName miss id=' + id + ' wantedPath=' + wantedPath + ' wantedFlat=' + wantedFlat + ' fields=' + Reflect.fields(list).join(","));
		return null;
	}

	static function __stripExtension(value:String):String {
		if (value == null) {
			return null;
		}

		var normalized = StringTools.replace(value, "\\", "/");
		var slash = normalized.lastIndexOf("/");
		var dot = normalized.lastIndexOf(".");
		return dot > slash ? normalized.substr(0, dot) : normalized;
	}

	static function __normalizePathKey(value:String, stripExtension:Bool):String {
		if (value == null) {
			return "";
		}

		var normalized = StringTools.replace(value, "\\", "/").toLowerCase();
		if (stripExtension) {
			normalized = __stripExtension(normalized);
		}
		while (normalized.indexOf("//") != -1) {
			normalized = StringTools.replace(normalized, "//", "/");
		}
		return normalized;
	}

	static function __normalizeFontKey(value:String):String {
		if (value == null) {
			return "";
		}

		var stripped = __stripExtension(value).toLowerCase();
		var buffer = new StringBuf();
		for (i in 0...stripped.length) {
			var code = stripped.charCodeAt(i);
			var isNumber = code >= "0".code && code <= "9".code;
			var isLower = code >= "a".code && code <= "z".code;
			if (isNumber || isLower) {
				buffer.addChar(code);
			}
		}
		return buffer.toString();
	}

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
