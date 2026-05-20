package openfl.text;

import kha.Assets;
import kha.graphics2.Graphics;
import openfl.Vector;
import openfl.display.InteractiveObject;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.geom.Rectangle;
import openfl.text._internal.HTMLParser;
import openfl.text._internal.TextFormatRange;

@:access(openfl.text.TextFormat)
class TextField extends InteractiveObject {
	@:allow(openfl.text._internal.TextEngine)
	static var __defaultTextFormat:TextFormat;

	public var autoSize(get, set):TextFieldAutoSize;
	public var background:Bool = false;
	public var backgroundColor:Int = 0xFFFFFF;
	public var border:Bool = false;
	public var borderColor:Int = 0x000000;
	public var bottomScrollV(get, never):Int;
	public var defaultTextFormat(get, set):TextFormat;
	public var displayAsPassword:Bool = false;
	public var embedFonts:Bool = false;
	public var gridFitType:GridFitType = GridFitType.PIXEL;
	public var htmlText(get, set):String;
	public var maxChars(get, set):Int;
	public var maxScrollH(get, never):Int;
	public var maxScrollV(get, never):Int;
	public var multiline:Bool = false;
	public var numLines(get, never):Int;
	public var scrollH(get, set):Int;
	public var scrollV(get, set):Int;
	public var selectable:Bool = true;
	public var selectionBeginIndex(get, never):Int;
	public var selectionEndIndex(get, never):Int;
	public var sharpness:Float = 0;
	public var text(get, set):String;
	public var textColor(get, set):Int;
	public var textHeight(get, never):Float;
	public var textWidth(get, never):Float;
	public var type(get, set):TextFieldType;
	public var wordWrap:Bool = false;

	@:allow(openfl.text._internal.TextEngine)
	var __textFormat:TextFormat;
	var __autoSize:TextFieldAutoSize = TextFieldAutoSize.NONE;
	var __charFormats:Array<TextFormat> = [];
	var __explicitHeight:Float = 100;
	var __explicitWidth:Float = 100;
	var __htmlText = "";
	var __maxChars = 0;
	var __scrollH = 0;
	var __scrollV = 1;
	var __selectionActive = 0;
	var __selectionAnchor = 0;
	@:allow(openfl.display._internal)
	var __styleSheet:Dynamic = null;
	var __tabEnabledOverride:Null<Bool> = null;
	var __text = "";
	var __textColor:Int = 0x000000;
	var __textFormatRanges:Vector<TextFormatRange>;
	var __type:TextFieldType = TextFieldType.DYNAMIC;
	var __autoSizeLeftAnchor:Float = 0;
	var __autoSizeRightAnchor:Float = 100;
	var __autoSizeCenterAnchor:Float = 50;

	public function new() {
		super();

		if (__defaultTextFormat == null) {
			__defaultTextFormat = new TextFormat();
		}

		__textFormat = __defaultTextFormat.clone();
		__textColor = __textFormat.color != null ? __textFormat.color : 0x000000;
		__textFormatRanges = new Vector<TextFormatRange>();
		__textFormatRanges.push(new TextFormatRange(__textFormat.clone(), 0, 0));
		__refreshAutoSizeAnchors();
	}

	override public function __render(g2:Graphics, offsetX:Float, offsetY:Float):Void {
		if (!__beginRender(g2, offsetX, offsetY)) {
			return;
		}

		var bounds = __getLocalBounds();
		var renderWidth = Math.max(1, bounds.width + 4);
		var renderHeight = Math.max(1, bounds.height + 4);

		if (background) {
			g2.color = __toColor(backgroundColor, 0xFF);
			g2.fillRect(0, 0, renderWidth, renderHeight);
		}

		if (border) {
			g2.color = __toColor(borderColor, 0xFF);
			g2.drawRect(0, 0, renderWidth, renderHeight, 1);
		}

		var font = openfl.utils.Assets.__getFontByName(embedFonts ? __textFormat.font : null);
		if (font == null && __textFormat != null && __textFormat.font != null) {
			font = openfl.utils.Assets.__getFontByName(__textFormat.font);
		}
		if (font == null) {
			font = Assets.fonts != null ? Assets.fonts.get("default_font") : null;
		}

		if (font != null) {
			g2.font = font;

			var size = __getFontSize();
			g2.fontSize = size;
			g2.color = __toColor(__textColor, 0xFF);

			var lines = __getDisplayLinesForRender();
			for (i in 0...lines.length) {
				g2.drawString(lines[i], 2, 2 + (i * __getLineHeight()));
			}
		}

		g2.color = kha.Color.White;
		__endRender(g2);
	}

	public function appendText(newText:String):Void {
		var suffix = newText == null ? "" : newText;
		__setPlainText(__text + suffix, true, true);
	}

	public function getLineMetrics(lineIndex:Int):TextLineMetrics {
		if (lineIndex < 0) {
			throw new RangeError("The supplied index is out of bounds.");
		}

		var lines = __getQueryLines();
		if (lineIndex >= lines.length) {
			return new TextLineMetrics(2, 0, 0, 0, 0, 0);
		}

		var text = lines[lineIndex].text;
		var width = __measureSingleLineWidth(text);
		var size = __getFontSize();
		var lineHeight = __getLineHeight();
		return new TextLineMetrics(2, width, lineHeight, size, size * 0.185, 0);
	}

	public function getLineOffset(lineIndex:Int):Int {
		if (lineIndex < 0) {
			throw new RangeError("The supplied index is out of bounds.");
		}

		var lines = __getQueryLines();
		return lineIndex < lines.length ? lines[lineIndex].offset : -1;
	}

	public function getLineText(lineIndex:Int):String {
		if (lineIndex < 0) {
			throw new RangeError("The supplied index is out of bounds.");
		}

		var lines = __getQueryLines();
		return lineIndex < lines.length ? lines[lineIndex].text : null;
	}

	public function getTextFormat(beginIndex:Int = -1, endIndex:Int = -1):TextFormat {
		if (__charFormats.length == 0 || (beginIndex == endIndex && beginIndex >= 0)) {
			return __textFormat.clone();
		}

		var start = beginIndex < 0 ? 0 : Std.int(Math.max(0, Math.min(beginIndex, __charFormats.length)));
		var finish = endIndex < 0 ? __charFormats.length : Std.int(Math.max(start, Math.min(endIndex, __charFormats.length)));
		if (start >= finish) {
			return __textFormat.clone();
		}

		var fields = ["font", "size", "color", "bold", "italic", "underline", "url", "target", "align", "leftMargin", "rightMargin", "indent",
			"leading", "blockIndent", "bullet", "kerning", "letterSpacing", "tabStops", "strikethrough"];
		var result = new TextFormat();
		var first = __charFormats[start];

		for (field in fields) {
			var value = Reflect.field(first, field);
			var matches = true;

			for (i in (start + 1)...finish) {
				if (!__formatValueEquals(value, Reflect.field(__charFormats[i], field))) {
					matches = false;
					break;
				}
			}

			Reflect.setField(result, field, matches ? value : null);
		}

		var commonColor = first.color;
		for (i in (start + 1)...finish) {
			if (!__formatValueEquals(commonColor, __charFormats[i].color)) {
				commonColor = null;
				break;
			}
		}
		result.color = commonColor;

		return result;
	}

	public function setSelection(beginIndex:Int, endIndex:Int):Void {
		var max = __text.length;
		var start = Std.int(Math.max(0, Math.min(beginIndex, max)));
		var finish = Std.int(Math.max(0, Math.min(endIndex, max)));
		__selectionAnchor = Std.int(Math.min(start, finish));
		__selectionActive = Std.int(Math.max(start, finish));
	}

	public function setTextFormat(format:TextFormat, beginIndex:Int = -1, endIndex:Int = -1):Void {
		if (format == null) {
			return;
		}

		if (__charFormats.length == 0) {
			return;
		}

		var start = beginIndex < 0 ? 0 : Std.int(Math.max(0, Math.min(beginIndex, __charFormats.length)));
		var finish = endIndex < 0 ? __charFormats.length : Std.int(Math.max(start, Math.min(endIndex, __charFormats.length)));
		for (i in start...finish) {
			__mergeFormat(__charFormats[i], format);
		}

		__rebuildRangesFromCharFormats();
	}

	@:allow(openfl.display._internal)
	function __updateText(value:String):Void {
		__text = value == null ? "" : value;
		if (__selectionAnchor > __text.length || __selectionActive > __text.length) {
			__selectionAnchor = __selectionActive = __text.length;
		}
	}

	@:allow(openfl.display)
	override function __getLocalBounds():Rectangle {
		return new Rectangle(0, 0, __getContentWidth(), __getContentHeight());
	}

	override function get_width():Float {
		return __autoSize == TextFieldAutoSize.NONE ? __explicitWidth : (__getContentWidth() + 4);
	}

	override function set_width(value:Float):Float {
		__explicitWidth = value;
		__refreshAutoSizeAnchors();
		__applyAutoSizePosition();
		return value;
	}

	override function get_height():Float {
		return __autoSize == TextFieldAutoSize.NONE ? __explicitHeight : (__getContentHeight() + 4);
	}

	override function set_height(value:Float):Float {
		__explicitHeight = value;
		return value;
	}

	override function get_tabEnabled():Bool {
		return __tabEnabledOverride == null ? (__type == TextFieldType.INPUT) : __tabEnabledOverride;
	}

	override function set_tabEnabled(value:Bool):Bool {
		__tabEnabledOverride = value;
		return value;
	}

	function get_autoSize():TextFieldAutoSize {
		return __autoSize;
	}

	function set_autoSize(value:TextFieldAutoSize):TextFieldAutoSize {
		if (value == null) {
			value = TextFieldAutoSize.NONE;
		}

		if (__autoSize == TextFieldAutoSize.NONE && value != TextFieldAutoSize.NONE) {
			__refreshAutoSizeAnchors();
		}

		__autoSize = value;
		__applyAutoSizePosition();
		return value;
	}

	function get_bottomScrollV():Int {
		return Std.int(Math.min(numLines, __scrollV + __visibleLineCount() - 1));
	}

	function get_defaultTextFormat():TextFormat {
		return __textFormat.clone();
	}

	function set_defaultTextFormat(value:TextFormat):TextFormat {
		__textFormat = value == null ? new TextFormat() : value.clone();
		if (__textFormat.color != null) {
			__textColor = __textFormat.color;
		}
		return value;
	}

	function get_htmlText():String {
		return __htmlText;
	}

	function set_htmlText(value:String):String {
		var html = value == null ? "" : value;
		__htmlText = html;
		__textFormatRanges = new Vector<TextFormatRange>();
		__textFormatRanges.push(new TextFormatRange(__textFormat.clone(), 0, 0));
		__text = HTMLParser.parse(html, multiline, null, __textFormat.clone(), __textFormatRanges);
		__syncCharFormatsWithRanges();
		__selectionAnchor = __selectionActive = __text.length;
		__applyAutoSizePosition();
		dispatchEvent(new Event(Event.CHANGE));
		return value;
	}

	function get_maxChars():Int {
		return __maxChars;
	}

	function set_maxChars(value:Int):Int {
		__maxChars = value < 0 ? 0 : value;
		if (__maxChars > 0 && __text.length > __maxChars) {
			__setPlainText(__text.substr(0, __maxChars), false, false);
		}
		return __maxChars;
	}

	function get_maxScrollH():Int {
		return textWidth > Math.max(0, __explicitWidth - 4) ? Std.int(Math.ceil(textWidth - Math.max(0, __explicitWidth - 4))) : 0;
	}

	function get_maxScrollV():Int {
		if (!multiline) {
			return 1;
		}
		return Std.int(Math.max(1, numLines - __visibleLineCount() + 1));
	}

	function get_numLines():Int {
		return __getQueryLines().length;
	}

	function get_scrollH():Int {
		return __scrollH;
	}

	function set_scrollH(value:Int):Int {
		var clamped = Std.int(Math.max(0, Math.min(value, maxScrollH)));
		if (clamped != __scrollH) {
			__scrollH = clamped;
			dispatchEvent(new Event(Event.SCROLL));
		}
		return __scrollH;
	}

	function get_scrollV():Int {
		return __scrollV;
	}

	function set_scrollV(value:Int):Int {
		var clamped = Std.int(Math.max(1, Math.min(value, maxScrollV)));
		if (clamped != __scrollV) {
			__scrollV = clamped;
			dispatchEvent(new Event(Event.SCROLL));
		}
		return __scrollV;
	}

	function get_selectionBeginIndex():Int {
		return Std.int(Math.min(__selectionAnchor, __selectionActive));
	}

	function get_selectionEndIndex():Int {
		return Std.int(Math.max(__selectionAnchor, __selectionActive));
	}

	function get_text():String {
		return __text;
	}

	function set_text(value:String):String {
		__setPlainText(value == null ? "" : value, false, false);
		dispatchEvent(new Event(Event.CHANGE));
		return value;
	}

	function get_textColor():Int {
		return __textColor;
	}

	function set_textColor(value:Int):Int {
		__textColor = value;
		__textFormat.color = value;
		for (format in __charFormats) {
			format.color = value;
		}
		__rebuildRangesFromCharFormats();
		return value;
	}

	function get_textHeight():Float {
		if (__text.length == 0) {
			return 0;
		}

		return __getMeasuredLineCount() * __getLineHeight();
	}

	function get_textWidth():Float {
		return __measureTextWidth(__getDisplayLinesForMeasure());
	}

	function get_type():TextFieldType {
		return __type;
	}

	function set_type(value:TextFieldType):TextFieldType {
		__type = value == null ? TextFieldType.DYNAMIC : value;
		return __type;
	}

	function __applyAutoSizePosition():Void {
		switch (__autoSize) {
			case LEFT:
				x = __autoSizeLeftAnchor;
			case RIGHT:
				x = __autoSizeRightAnchor - get_width();
			case CENTER:
				x = __autoSizeCenterAnchor - (get_width() * 0.5);
			case NONE:
		}
	}

	function __buildPlainCharFormats():Void {
		__charFormats = [];
		for (i in 0...__text.length) {
			__charFormats.push(__textFormat.clone());
		}
		__rebuildRangesFromCharFormats();
	}

	function __getContentHeight():Float {
		if (__text.length == 0) {
			return 0;
		}

		var lineCount = __getMeasuredLineCount();
		var height = lineCount * __getLineHeight();
		if (__autoSize == TextFieldAutoSize.NONE) {
			height = Math.max(height, Math.max(0, __explicitHeight - 4));
		}
		return height;
	}

	function __getContentWidth():Float {
		if (__text.length == 0) {
			return 0;
		}

		var width = __measureTextWidth(__getDisplayLinesForMeasure());
		if (__autoSize == TextFieldAutoSize.NONE) {
			width = Math.max(width, Math.max(0, __explicitWidth - 4));
		}
		return width;
	}

	function __getDisplayLinesForMeasure():Array<String> {
		if (__text.length == 0) {
			return [];
		}

		var lines = __getDisplayText().split("\n");
		if (multiline && __type != TextFieldType.INPUT && __text.length > 0 && __text.charAt(__text.length - 1) == "\n" && lines.length > 1) {
			lines.pop();
		}
		return lines;
	}

	function __getDisplayLinesForRender():Array<String> {
		var lines = __getDisplayLinesForMeasure();
		return lines.length == 0 ? [""] : lines;
	}

	function __getDisplayText():String {
		if (!displayAsPassword) {
			return __text;
		}

		var buffer = "";
		for (i in 0...__text.length) {
			buffer += (__text.charAt(i) == "\n") ? "\n" : "*";
		}
		return buffer;
	}

	function __getFontSize():Int {
		return __textFormat.size == null ? 12 : __textFormat.size;
	}

	function __getLineHeight():Float {
		return __getFontSize() + 4;
	}

	function __getMeasuredLineCount():Int {
		if (__text.length == 0) {
			return 0;
		}

		var lines = __getDisplayLinesForMeasure();
		return lines.length == 0 ? 1 : lines.length;
	}

	function __getQueryLines():Array<{ offset:Int, text:String }> {
		var result:Array<{ offset:Int, text:String }> = [];
		if (__text.length == 0) {
			result.push({ offset: 0, text: "" });
			return result;
		}

		var start = 0;
		for (i in 0...__text.length) {
			if (__text.charAt(i) == "\n") {
				result.push({ offset: start, text: __text.substring(start, i + 1) });
				start = i + 1;
			}
		}

		if (start < __text.length || result.length == 0) {
			result.push({ offset: start, text: __text.substring(start) });
		}

		return result;
	}

	function __measureSingleLineWidth(line:String):Float {
		if (line == null || line.length == 0) {
			return 0;
		}

		var printable = StringTools.replace(line, "\n", "");
		return printable.length * __getFontSize() * 0.58;
	}

	function __measureTextWidth(lines:Array<String>):Float {
		if (lines == null || lines.length == 0) {
			return 0;
		}

		var longest = 0.0;
		for (line in lines) {
			var lineWidth = __measureSingleLineWidth(line);
			if (lineWidth > longest) {
				longest = lineWidth;
			}
		}
		return longest;
	}

	function __mergeFormat(target:TextFormat, source:TextFormat):Void {
		if (source.font != null) target.font = source.font;
		if (source.size != null) target.size = source.size;
		if (source.color != null) target.color = source.color;
		if (source.bold != null) target.bold = source.bold;
		if (source.italic != null) target.italic = source.italic;
		if (source.underline != null) target.underline = source.underline;
		if (source.url != null) target.url = source.url;
		if (source.target != null) target.target = source.target;
		if (source.align != null) target.align = source.align;
		if (source.leftMargin != null) target.leftMargin = source.leftMargin;
		if (source.rightMargin != null) target.rightMargin = source.rightMargin;
		if (source.indent != null) target.indent = source.indent;
		if (source.leading != null) target.leading = source.leading;
		if (source.blockIndent != null) target.blockIndent = source.blockIndent;
		if (source.bullet != null) target.bullet = source.bullet;
		if (source.kerning != null) target.kerning = source.kerning;
		if (source.letterSpacing != null) target.letterSpacing = source.letterSpacing;
		if (source.tabStops != null) target.tabStops = source.tabStops.copy();
		if (source.strikethrough != null) target.strikethrough = source.strikethrough;
		if (source.__ascent != null) target.__ascent = source.__ascent;
		if (source.__descent != null) target.__descent = source.__descent;
	}

	function __rebuildRangesFromCharFormats():Void {
		__textFormatRanges = new Vector<TextFormatRange>();
		if (__charFormats.length == 0) {
			__textFormatRanges.push(new TextFormatRange(__textFormat.clone(), 0, 0));
			return;
		}

		var start = 0;
		var current = __charFormats[0].clone();
		for (i in 1...__charFormats.length) {
			if (!__formatsMatch(current, __charFormats[i])) {
				__textFormatRanges.push(new TextFormatRange(current, start, i));
				start = i;
				current = __charFormats[i].clone();
			}
		}
		__textFormatRanges.push(new TextFormatRange(current, start, __charFormats.length));
	}

	function __refreshAutoSizeAnchors():Void {
		__autoSizeLeftAnchor = x;
		__autoSizeRightAnchor = x + __explicitWidth;
		__autoSizeCenterAnchor = x + (__explicitWidth * 0.5);
	}

	function __setPlainText(value:String, collapseSelectionToEnd:Bool, preserveHtml:Bool):Void {
		var nextValue = value == null ? "" : value;
		if (__maxChars > 0 && nextValue.length > __maxChars) {
			nextValue = nextValue.substr(0, __maxChars);
		}

		__text = nextValue;
		__htmlText = preserveHtml ? __htmlText : nextValue;
		__buildPlainCharFormats();
		if (collapseSelectionToEnd) {
			__selectionAnchor = __selectionActive = __text.length;
		} else {
			__selectionAnchor = __selectionActive = 0;
		}
		__applyAutoSizePosition();
	}

	function __syncCharFormatsWithRanges():Void {
		__charFormats = [];
		for (i in 0...__text.length) {
			__charFormats.push(__textFormat.clone());
		}

		for (range in __textFormatRanges) {
			var start = Std.int(Math.max(0, Math.min(range.start, __text.length)));
			var finish = Std.int(Math.max(start, Math.min(range.end, __text.length)));
			for (i in start...finish) {
				__charFormats[i] = range.format.clone();
			}
		}

		__rebuildRangesFromCharFormats();
	}

	function __visibleLineCount():Int {
		var lineHeight = __getLineHeight();
		if (lineHeight <= 0) {
			return 1;
		}
		var availableHeight = Math.max(0, __explicitHeight - 4);
		return Std.int(Math.max(1, Math.floor(availableHeight / lineHeight)));
	}

	static function __formatValueEquals(a:Dynamic, b:Dynamic):Bool {
		if (a == b) {
			return true;
		}

		if (Std.isOfType(a, Array) && Std.isOfType(b, Array)) {
			return Std.string(a) == Std.string(b);
		}

		return false;
	}

	static function __formatsMatch(a:TextFormat, b:TextFormat):Bool {
		var fields = ["font", "size", "color", "bold", "italic", "underline", "url", "target", "align", "leftMargin", "rightMargin", "indent",
			"leading", "blockIndent", "bullet", "kerning", "letterSpacing", "tabStops", "strikethrough"];

		for (field in fields) {
			if (!__formatValueEquals(Reflect.field(a, field), Reflect.field(b, field))) {
				return false;
			}
		}

		return true;
	}

	static function __toColor(color:Int, alpha:Int):kha.Color {
		return kha.Color.fromBytes((color >> 16) & 0xFF, (color >> 8) & 0xFF, color & 0xFF, alpha);
	}
}
