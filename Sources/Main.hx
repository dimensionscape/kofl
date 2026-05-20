package;

import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;

class Main extends Sprite {
	var accentBlob:Sprite;
	var badge:Bitmap;
	var card:Sprite;
	var glowBar:Shape;
	var info:TextField;
	var input:TextField;
	var log:TextField;
	var orbit = 0.0;

	public function new() {
		super();

		addChild(makeBackdrop());
		card = makeCard();
		addChild(card);

		accentBlob = makeAccentBlob();
		accentBlob.x = 660;
		accentBlob.y = 210;
		addChild(accentBlob);

		glowBar = new Shape();
		glowBar.x = 120;
		glowBar.y = 106;
		glowBar.graphics.beginFill(0xF6C945);
		glowBar.graphics.drawRoundRect(0, 0, 160, 10, 10, 10);
		glowBar.graphics.endFill();
		addChild(glowBar);

		var title = makeLabel("KOFL / OpenFL on Kha", 34, 0xF5F7FF);
		title.x = 120;
		title.y = 112;
		addChild(title);

		var subtitle = makeLabel("Real openfl.* classes, Kha underneath, no Lime internals in sight.", 18, 0x9CA8C7);
		subtitle.x = 122;
		subtitle.y = 160;
		addChild(subtitle);

		info = makeLabel("Click the card, type in the field, watch the pixel badge animate.", 18, 0xDDE6FF);
		info.x = 122;
		info.y = 504;
		addChild(info);

		input = new TextField();
		input.type = TextFieldType.INPUT;
		input.background = true;
		input.backgroundColor = 0xF5F8FF;
		input.border = true;
		input.borderColor = 0x24304D;
		input.textColor = 0x162033;
		input.defaultTextFormat = new TextFormat("_sans", 20, 0x162033);
		input.text = "type here";
		input.x = 124;
		input.y = 546;
		addChild(input);

		log = makeLabel("Events: waiting", 16, 0x92A1C6);
		log.x = 126;
		log.y = 594;
		addChild(log);

		card.addEventListener(MouseEvent.CLICK, onCardClick);
		input.addEventListener(MouseEvent.CLICK, onInputClick);
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	function onAddedToStage(_:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
		input.addEventListener(FocusEvent.FOCUS_IN, onInputFocusIn);
		input.addEventListener(FocusEvent.FOCUS_OUT, onInputFocusOut);
	}

	function makeBackdrop():Sprite {
		var sprite = new Sprite();

		var sky = new Shape();
		sky.graphics.beginFill(0x0A1020);
		sky.graphics.drawRect(0, 0, 960, 540);
		sky.graphics.endFill();
		sprite.addChild(sky);

		var panel = new Shape();
		panel.graphics.beginFill(0x111A33);
		panel.graphics.drawRoundRect(64, 72, 832, 590, 38, 38);
		panel.graphics.endFill();
		sprite.addChild(panel);

		var stripe = new Shape();
		stripe.graphics.beginFill(0x1D2A4D);
		stripe.graphics.drawRoundRect(92, 90, 776, 20, 12, 12);
		stripe.graphics.endFill();
		sprite.addChild(stripe);

		return sprite;
	}

	function makeCard():Sprite {
		var sprite = new Sprite();
		sprite.x = 122;
		sprite.y = 230;

		var panel = new Shape();
		panel.graphics.beginFill(0x182544);
		panel.graphics.drawRoundRect(0, 0, 452, 220, 28, 28);
		panel.graphics.endFill();
		sprite.addChild(panel);

		var shadow = new Shape();
		shadow.alpha = 0.35;
		shadow.y = 190;
		shadow.graphics.beginFill(0x05070B);
		shadow.graphics.drawEllipse(28, 0, 340, 26);
		shadow.graphics.endFill();
		sprite.addChild(shadow);

		badge = new Bitmap(makeBadgeBitmap());
		badge.x = 30;
		badge.y = 32;
		badge.scaleX = 3;
		badge.scaleY = 3;
		sprite.addChild(badge);

		var heading = makeLabel("Interactive Pixel Badge", 24, 0xFFFFFF);
		heading.x = 172;
		heading.y = 38;
		sprite.addChild(heading);

		var body = makeLabel("This card is a normal openfl.display.Sprite.\nClicks bubble, BitmapData stores pixels,\nand TextField input rides the Kha event loop.", 17, 0xBCD0FF);
		body.x = 174;
		body.y = 86;
		sprite.addChild(body);

		return sprite;
	}

	function makeAccentBlob():Sprite {
		var sprite = new Sprite();

		var outer = new Shape();
		outer.graphics.beginFill(0x23375F);
		outer.graphics.drawCircle(0, 0, 128);
		outer.graphics.endFill();
		sprite.addChild(outer);

		var inner = new Shape();
		inner.graphics.beginFill(0xEE5A5A);
		inner.graphics.drawCircle(24, -12, 74);
		inner.graphics.endFill();
		sprite.addChild(inner);

		var chip = new Shape();
		chip.graphics.beginFill(0xF6C945);
		chip.graphics.drawRoundRect(-72, 52, 148, 40, 18, 18);
		chip.graphics.endFill();
		sprite.addChild(chip);

		var tag = makeLabel("KHA BACKEND", 16, 0x172238);
		tag.x = -46;
		tag.y = 62;
		sprite.addChild(tag);

		return sprite;
	}

	function makeBadgeBitmap():BitmapData {
		var data = new BitmapData(18, 18, true, 0x00000000);

		for (y in 0...18) {
			for (x in 0...18) {
				var dx = x - 9;
				var dy = y - 9;
				var dist = Math.sqrt(dx * dx + dy * dy);
				if (dist < 8.6) {
					var color = dist < 4.2 ? 0xFFF6C945 : 0xFF4CC9F0;
					data.setPixel32(x, y, color);
				}
			}
		}

		for (i in 4...14) {
			data.setPixel32(i, 3, 0xFF162033);
			data.setPixel32(i, 14, 0xFF162033);
			data.setPixel32(3, i, 0xFF162033);
			data.setPixel32(14, i, 0xFF162033);
		}

		return data;
	}

	function makeLabel(text:String, size:Int, color:Int):TextField {
		var field = new TextField();
		field.autoSize = TextFieldAutoSize.LEFT;
		field.selectable = false;
		field.defaultTextFormat = new TextFormat("_sans", size, color);
		field.textColor = color;
		field.text = text;
		return field;
	}

	function onCardClick(_:MouseEvent):Void {
		card.rotation += 7;
		log.text = "Events: card clicked, bubbling through Sprite hierarchy";
		info.text = "Card click reached the target sprite. KOFL is dispatching into real openfl events.";
	}

	function onInputClick(_:MouseEvent):Void {
		stage.focus = input;
		if (input.text == "type here") {
			input.text = "";
		}
		log.text = "Events: input focused, keyboard text goes into TextField";
	}

	function onInputFocusIn(_:FocusEvent):Void {
		input.borderColor = 0xF6C945;
		info.text = "Focus is on the input. Type to send native key events into the TextField.";
	}

	function onInputFocusOut(_:FocusEvent):Void {
		input.borderColor = 0x24304D;
		if (input.text == "") {
			input.text = "type here";
		}
	}

	function onEnterFrame(_:Event):Void {
		orbit += 1 / 60;
		accentBlob.rotation = Math.sin(orbit * 0.8) * 8;
		accentBlob.scaleX = 1 + Math.sin(orbit * 1.4) * 0.05;
		accentBlob.scaleY = 1 + Math.sin(orbit * 1.4) * 0.05;
		glowBar.scaleX = 1 + Math.sin(orbit * 1.2) * 0.25;
		badge.rotation = Math.sin(orbit * 2.4) * 7;
		card.y = 230 + Math.sin(orbit * 1.1) * 6;
	}

	function onKeyDown(event:KeyboardEvent):Void {
		log.text = "Events: keyDown " + event.keyCode + " / focus = " + (stage.focus == input ? "input" : "other");

		if (event.keyCode == 13) {
			info.text = "Typed: " + input.text;
		}
	}

	function onStageMouseDown(_:MouseEvent):Void {
		if (stage.focus == input) {
			log.text = "Events: mouseDown / focus = input";
		} else if (stage.focus != null) {
			log.text = "Events: mouseDown / focus moved away from input";
		} else {
			log.text = "Events: mouseDown / focus cleared";
		}
	}

	public static function main():Void {
		Lib.start({
			title: "KOFL Interactive OpenFL Example",
			width: 960,
			height: 720,
			backgroundColor: 0x08101D
		}, function() {
			return new Main();
		});
	}
}
