package openfl.text;

class Font {
	public var fontName(default, null):String;
	public var fontStyle(default, null):FontStyle;
	public var fontType(default, null):FontType;
	@:allow(openfl.utils.Assets)
	var __khaFont:kha.Font;

	@:allow(openfl.text._internal.TextEngine)
	static var __fontByName:Map<String, Font> = new Map();
	static var __registeredFonts:Array<Font> = [];

	public function new(name:String = null, style:FontStyle = null, type:FontType = null, khaFont:kha.Font = null) {
		fontName = name;
		fontStyle = style;
		fontType = type == null ? (khaFont != null ? FontType.EMBEDDED : null) : type;
		__khaFont = khaFont;
	}

	public static function enumerateFonts(enumerateDeviceFonts:Bool = false):Array<Font> {
		var result = __registeredFonts.copy();
		if (enumerateDeviceFonts) {
			result.push(new Font());
		}
		return result;
	}

	public static function registerFont(font:Dynamic):Void {
		var instance:Font = Type.getClass(font) == null ? cast Type.createInstance(font, []) : cast font;
		if (instance == null) {
			return;
		}

		for (registered in __registeredFonts) {
			if (registered.fontName == instance.fontName) {
				__fontByName[instance.fontName] = registered;
				return;
			}
		}

		__registeredFonts.push(instance);
		__fontByName[instance.fontName] = instance;
	}

	@:allow(openfl.utils.Assets)
	static function __fromAsset(id:String, khaFont:kha.Font):Font {
		var normalized = StringTools.replace(id, "\\", "/");
		var slash = normalized.lastIndexOf("/");
		var dot = normalized.lastIndexOf(".");
		var name = slash >= 0 ? normalized.substr(slash + 1) : normalized;
		if (dot > slash) {
			name = normalized.substr(slash + 1, dot - slash - 1);
		}

		var font = new Font(name, FontStyle.REGULAR, FontType.EMBEDDED, khaFont);
		registerFont(font);
		return font;
	}
}
