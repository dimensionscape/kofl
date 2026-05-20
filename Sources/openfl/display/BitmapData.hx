package openfl.display;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import openfl.Vector;
import openfl.filters.BitmapFilter;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import openfl.utils.Future;

@:autoBuild(openfl.utils._internal.AssetsMacro.embedBitmap())
class BitmapData {
	public var fillColor:kha.Color;
	public var height(default, null):Int;
	public var image(default, null):Dynamic;
	public var readable(default, null):Bool;
	public var rect(default, null):Rectangle;
	public var transparent(default, null):Bool;
	public var width(default, null):Int;

	var __pixels:Array<Int>;
	@:allow(openfl.display.Bitmap)
	var __image:kha.Image;

	public function new(width:Int, height:Int, transparent:Bool = true, fillColor:Int = 0xFFFFFFFF) {
		this.width = width < 0 ? 0 : width;
		this.height = height < 0 ? 0 : height;
		this.transparent = transparent;
		this.rect = new Rectangle(0, 0, this.width, this.height);
		this.fillColor = __toColor(fillColor);
		this.readable = true;
		__pixels = [];
		image = { premultiplied: false };

		var pixel = __normalizePixelForStorage(fillColor, transparent);
		for (i in 0...(this.width * this.height)) {
			__pixels.push(pixel);
		}
	}

	public function applyFilter(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, filter:BitmapFilter):Void {
		if (!readable || sourceBitmapData == null || sourceRect == null || destPoint == null) {
			return;
		}

		copyPixels(sourceBitmapData, sourceRect, destPoint);
	}

	public function clone():BitmapData {
		var copy = new BitmapData(width, height, transparent, 0);
		copy.__pixels = __pixels.copy();
		copy.fillColor = fillColor;
		copy.__image = __image;
		copy.image.premultiplied = image != null && Reflect.hasField(image, "premultiplied") ? Reflect.field(image, "premultiplied") : false;
		copy.readable = readable;
		return copy;
	}

	public function colorTransform(rectangle:Rectangle, colorTransform:ColorTransform):Void {
		if (!readable || rectangle == null || colorTransform == null) {
			return;
		}

		var minX = Std.int(Math.max(0, rectangle.x));
		var minY = Std.int(Math.max(0, rectangle.y));
		var maxX = Std.int(Math.min(width, rectangle.x + rectangle.width));
		var maxY = Std.int(Math.min(height, rectangle.y + rectangle.height));

		__invalidateImage();

		for (y in minY...maxY) {
			for (x in minX...maxX) {
				__setPixel32(x, y, __applyColorTransformToPixel(__getPixel32(x, y), colorTransform));
			}
		}
	}

	public function compare(otherBitmapData:BitmapData):Dynamic {
		if (otherBitmapData == null) {
			return -1;
		}

		if (!readable || !otherBitmapData.readable) {
			return -2;
		}

		if (width != otherBitmapData.width) {
			return -3;
		}

		if (height != otherBitmapData.height) {
			return -4;
		}

		var difference:BitmapData = null;

		for (i in 0...(width * height)) {
			var pixelA = __pixels[i];
			var pixelB = otherBitmapData.__pixels[i];
			if (pixelA == pixelB) {
				continue;
			}

			if (difference == null) {
				difference = new BitmapData(width, height, true, 0x00000000);
			}

			var alphaA = (pixelA >> 24) & 0xFF;
			var redA = (pixelA >> 16) & 0xFF;
			var greenA = (pixelA >> 8) & 0xFF;
			var blueA = pixelA & 0xFF;

			var alphaB = (pixelB >> 24) & 0xFF;
			var redB = (pixelB >> 16) & 0xFF;
			var greenB = (pixelB >> 8) & 0xFF;
			var blueB = pixelB & 0xFF;

			difference.__pixels[i] = if (redA != redB || greenA != greenB || blueA != blueB) {
				(0xFF << 24) | (Std.int(Math.abs(redA - redB)) << 16) | (Std.int(Math.abs(greenA - greenB)) << 8) | Std.int(Math.abs(blueA - blueB));
			} else {
				(Std.int(Math.abs(alphaA - alphaB)) << 24) | 0xFFFFFF;
			};
		}

		return difference == null ? 0 : difference;
	}

	public function copyChannel(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, sourceChannel:BitmapDataChannel, destChannel:BitmapDataChannel):Void {
		if (!readable || sourceBitmapData == null || sourceRect == null || destPoint == null) {
			return;
		}

		var minX = Std.int(Math.max(0, sourceRect.x));
		var minY = Std.int(Math.max(0, sourceRect.y));
		var maxX = Std.int(Math.min(sourceBitmapData.width, sourceRect.x + sourceRect.width));
		var maxY = Std.int(Math.min(sourceBitmapData.height, sourceRect.y + sourceRect.height));

		__invalidateImage();

		for (y in minY...maxY) {
			for (x in minX...maxX) {
				var destX = Std.int(destPoint.x + (x - minX));
				var destY = Std.int(destPoint.y + (y - minY));
				if (destX < 0 || destY < 0 || destX >= width || destY >= height) {
					continue;
				}

				var sourcePixel = sourceBitmapData.getPixel32(x, y);
				var destPixel = getPixel32(destX, destY);
				var channelValue = __readChannel(sourcePixel, sourceChannel);
				destPixel = __writeChannel(destPixel, destChannel, channelValue, transparent);
				__setPixel32(destX, destY, destPixel);
			}
		}
	}

	public function copyPixels(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, alphaBitmapData:BitmapData = null, alphaPoint:Point = null,
			mergeAlpha:Bool = false):Void {
		if (!readable || sourceBitmapData == null || sourceRect == null || destPoint == null) {
			return;
		}

		var minX = Std.int(Math.max(0, sourceRect.x));
		var minY = Std.int(Math.max(0, sourceRect.y));
		var maxX = Std.int(Math.min(sourceBitmapData.width, sourceRect.x + sourceRect.width));
		var maxY = Std.int(Math.min(sourceBitmapData.height, sourceRect.y + sourceRect.height));

		__invalidateImage();

		for (y in minY...maxY) {
			for (x in minX...maxX) {
				var destX = Std.int(destPoint.x + (x - minX));
				var destY = Std.int(destPoint.y + (y - minY));
				if (destX < 0 || destY < 0 || destX >= width || destY >= height) {
					continue;
				}

				var sourcePixel = sourceBitmapData.getPixel32(x, y);
				if (alphaBitmapData != null) {
					var alphaX = alphaPoint != null ? Std.int(alphaPoint.x + (x - minX)) : x;
					var alphaY = alphaPoint != null ? Std.int(alphaPoint.y + (y - minY)) : y;
					var alpha = (alphaBitmapData.getPixel32(alphaX, alphaY) >> 24) & 0xFF;
					sourcePixel = (alpha << 24) | (sourcePixel & 0xFFFFFF);
				}

				if (mergeAlpha) {
					var destinationPixel = getPixel32(destX, destY);
					var sourceAlpha = ((sourcePixel >> 24) & 0xFF) / 255;
					var destAlpha = ((destinationPixel >> 24) & 0xFF) / 255;
					var outAlpha = sourceAlpha + (destAlpha * (1 - sourceAlpha));
					if (outAlpha <= 0) {
						__setPixel32(destX, destY, 0);
						continue;
					}

					var sourceRed = (sourcePixel >> 16) & 0xFF;
					var sourceGreen = (sourcePixel >> 8) & 0xFF;
					var sourceBlue = sourcePixel & 0xFF;
					var destRed = (destinationPixel >> 16) & 0xFF;
					var destGreen = (destinationPixel >> 8) & 0xFF;
					var destBlue = destinationPixel & 0xFF;

					var red = Std.int(((sourceRed * sourceAlpha) + (destRed * destAlpha * (1 - sourceAlpha))) / outAlpha);
					var green = Std.int(((sourceGreen * sourceAlpha) + (destGreen * destAlpha * (1 - sourceAlpha))) / outAlpha);
					var blue = Std.int(((sourceBlue * sourceAlpha) + (destBlue * destAlpha * (1 - sourceAlpha))) / outAlpha);
					var alpha = Std.int(outAlpha * 255);
					__setPixel32(destX, destY, (alpha << 24) | (red << 16) | (green << 8) | blue);
				} else {
					__setPixel32(destX, destY, sourcePixel);
				}
			}
		}
	}

	public function dispose():Void {
		__pixels = [];
		__image = null;
		width = 0;
		height = 0;
		rect.setEmpty();
		fillColor = __toColor(0);
		readable = false;
	}

	public function draw(source:Dynamic, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:BlendMode = null, clipRect:Rectangle = null,
			smoothing:Bool = false):Void {
		if (!readable || source == null) {
			return;
		}

		if (Std.isOfType(source, BitmapData)) {
			__drawBitmapData(cast source, matrix, colorTransform, clipRect);
			return;
		}

		if (Std.isOfType(source, Bitmap)) {
			var bitmap:Bitmap = cast source;
			if (bitmap.bitmapData != null) {
				__drawBitmapData(bitmap.bitmapData, matrix, colorTransform, clipRect);
			}
			return;
		}

		if (Std.isOfType(source, openfl.display.DisplayObject)) {
			var rootMatrix = matrix == null ? new Matrix() : matrix.clone();
			__drawDisplayObject(cast source, rootMatrix, false, colorTransform, clipRect);
			return;
		}

		if (Reflect.hasField(source, "visible") && !Reflect.field(source, "visible")) {
			return;
		}
	}

	public function drawWithQuality(source:Dynamic, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:BlendMode = null,
			clipRect:Rectangle = null, smoothing:Bool = false, quality:Dynamic = null):Void {
		draw(source, matrix, colorTransform, blendMode, clipRect, smoothing);
	}

	public function encode(rect:Rectangle, compressor:Dynamic, byteArray:ByteArray = null):ByteArray {
		var targetRect = rect == null ? this.rect : rect;
		var bytes = byteArray == null ? new ByteArray() : byteArray;
		var pixels = getPixels(targetRect);
		bytes.clear();
		bytes.writeBytes(pixels, 0, pixels.length);
		bytes.position = 0;
		return bytes;
	}

	public function floodFill(x:Int, y:Int, color:Int):Void {
		if (!readable || x < 0 || y < 0 || x >= width || y >= height) {
			return;
		}

		var target = getPixel32(x, y);
		var replacement = transparent ? color : (0xFF000000 | (color & 0xFFFFFF));
		if (target == replacement) {
			return;
		}

		__invalidateImage();

		var queue = [new Point(x, y)];
		while (queue.length > 0) {
			var point = queue.shift();
			var px = Std.int(point.x);
			var py = Std.int(point.y);
			if (px < 0 || py < 0 || px >= width || py >= height) {
				continue;
			}

			if (__getPixel32(px, py) != target) {
				continue;
			}

			__setPixel32(px, py, replacement);
			queue.push(new Point(px + 1, py));
			queue.push(new Point(px - 1, py));
			queue.push(new Point(px, py + 1));
			queue.push(new Point(px, py - 1));
		}
	}

	public function fillRect(rectangle:Rectangle, color:Int):Void {
		if (!readable || rectangle == null) {
			return;
		}

		var minX = Std.int(Math.max(0, rectangle.x));
		var minY = Std.int(Math.max(0, rectangle.y));
		var maxX = Std.int(Math.min(width, rectangle.x + rectangle.width));
		var maxY = Std.int(Math.min(height, rectangle.y + rectangle.height));
		__invalidateImage();

		for (y in minY...maxY) {
			for (x in minX...maxX) {
				__setPixel32(x, y, transparent ? color : (0xFF000000 | (color & 0xFFFFFF)));
			}
		}
	}

	public static function fromBase64(base64:String, type:String):BitmapData {
		if (base64 == null) {
			return null;
		}

		try {
			var decoded:Bytes = Base64.decode(base64);
			var byteArray:ByteArray = decoded;
			return fromBytes(byteArray);
		} catch (e:Dynamic) {
			return new BitmapData(1, 1, true, 0x00000000);
		}
	}

	public static function fromBytes(bytes:ByteArray, rawAlpha:ByteArray = null):BitmapData {
		if (bytes == null) {
			return null;
		}

		var detectedFormat = __detectEncodedImageFormat(bytes);
		if (detectedFormat != null) {
			__trace('BitmapData.fromBytes detected format=' + detectedFormat + ' length=' + bytes.length);
			var loaded:BitmapData = null;
			var sourceBytes:haxe.io.Bytes = bytes;
			__trace('BitmapData.fromBytes before fromEncodedBytes');
			kha.Image.fromEncodedBytes(sourceBytes, detectedFormat, function(image) {
				__trace('BitmapData.fromBytes in fromEncodedBytes callback image=' + (image != null));
				loaded = __fromKhaImage(image);
				__trace('BitmapData.fromBytes after __fromKhaImage loaded=' + (loaded != null ? (loaded.width + "x" + loaded.height) : "null"));
			}, function(error) {
				__trace('BitmapData.fromBytes error callback=' + error);
			}, true);
			__trace('BitmapData.fromBytes after fromEncodedBytes loaded=' + (loaded != null));

			if (loaded != null) {
				if (rawAlpha != null && rawAlpha.length > 0) {
					rawAlpha.position = 0;
					for (y in 0...loaded.height) {
						for (x in 0...loaded.width) {
							if (rawAlpha.bytesAvailable <= 0) {
								break;
							}

							var pixel = loaded.getPixel32(x, y);
							var alpha = rawAlpha.readUnsignedByte();
							loaded.setPixel32(x, y, (alpha << 24) | (pixel & 0xFFFFFF));
						}
					}
				}

				return loaded;
			}
		}

		var bitmapData = new BitmapData(1, 1, true, 0x00000000);
		if (bytes.length >= 4) {
			bytes.position = 0;
			bitmapData.setPixel32(0, 0, bytes.readInt());
		}

		if (rawAlpha != null && rawAlpha.length > 0) {
			rawAlpha.position = 0;
			var pixel = bitmapData.getPixel32(0, 0);
			var alpha = rawAlpha.readUnsignedByte();
			bitmapData.setPixel32(0, 0, (alpha << 24) | (pixel & 0xFFFFFF));
		}

		return bitmapData;
	}

	public static function fromCanvas(canvas:Dynamic):BitmapData {
		if (canvas == null) {
			return null;
		}

		var canvasWidth = Reflect.hasField(canvas, "width") ? Std.int(Reflect.field(canvas, "width")) : 1;
		var canvasHeight = Reflect.hasField(canvas, "height") ? Std.int(Reflect.field(canvas, "height")) : 1;
		return new BitmapData(canvasWidth, canvasHeight, true, 0x00000000);
	}

	public static function fromFile(path:String):BitmapData {
		#if sys
		if (path != null && sys.FileSystem.exists(path)) {
			var bytes:ByteArray = sys.io.File.getBytes(path);
			return fromBytes(bytes);
		}
		#end

		return new BitmapData(1, 1, true, 0x00000000);
	}

	public static function fromImage(image:Dynamic, transparent:Bool = true):BitmapData {
		if (image == null) {
			return null;
		}

		if (Std.isOfType(image, BitmapData)) {
			return cast(image, BitmapData).clone();
		}

		if (Std.isOfType(image, kha.Image)) {
			return __fromKhaImage(cast image);
		}

		var imageWidth = Reflect.hasField(image, "width") ? Std.int(Reflect.field(image, "width")) : 1;
		var imageHeight = Reflect.hasField(image, "height") ? Std.int(Reflect.field(image, "height")) : 1;
		return new BitmapData(imageWidth, imageHeight, transparent, 0x00000000);
	}

	public function generateFilterRect(sourceRect:Rectangle, filter:BitmapFilter):Rectangle {
		if (sourceRect == null) {
			return new Rectangle();
		}

		var padding = __getFilterPadding(filter);
		return new Rectangle(sourceRect.x - padding.x, sourceRect.y - padding.y, sourceRect.width + (padding.x * 2), sourceRect.height + (padding.y * 2));
	}

	public function getColorBoundsRect(mask:Int = 0xFFFFFFFF, color:Int = 0xFFFFFFFF, findColor:Bool = true):Rectangle {
		if (!readable || width == 0 || height == 0) {
			return new Rectangle();
		}

		var found = false;
		var minX = width;
		var minY = height;
		var maxX = -1;
		var maxY = -1;

		for (y in 0...height) {
			for (x in 0...width) {
				var matched = ((__getPixel32(x, y) & mask) == (color & mask));
				if (matched == findColor) {
					found = true;
					if (x < minX) minX = x;
					if (y < minY) minY = y;
					if (x > maxX) maxX = x;
					if (y > maxY) maxY = y;
				}
			}
		}

		return found ? new Rectangle(minX, minY, (maxX - minX) + 1, (maxY - minY) + 1) : new Rectangle();
	}

	public function getPixel(x:Int, y:Int):Int {
		return __getPixel32(x, y) & 0xFFFFFF;
	}

	public function getPixel32(x:Int, y:Int):Int {
		return __getPixel32(x, y);
	}

	public function getPixels(rectangle:Rectangle):ByteArray {
		var bytes = new ByteArray();
		if (!readable || rectangle == null) {
			return bytes;
		}

		var minX = Std.int(Math.max(0, rectangle.x));
		var minY = Std.int(Math.max(0, rectangle.y));
		var maxX = Std.int(Math.min(width, rectangle.x + rectangle.width));
		var maxY = Std.int(Math.min(height, rectangle.y + rectangle.height));

		for (y in minY...maxY) {
			for (x in minX...maxX) {
				bytes.writeInt(getPixel32(x, y));
			}
		}

		bytes.position = 0;
		return bytes;
	}

	public function getVector(rectangle:Rectangle):Vector<UInt> {
		var result = new Vector<UInt>();
		if (!readable || rectangle == null) {
			return result;
		}

		var minX = Std.int(Math.max(0, rectangle.x));
		var minY = Std.int(Math.max(0, rectangle.y));
		var maxX = Std.int(Math.min(width, rectangle.x + rectangle.width));
		var maxY = Std.int(Math.min(height, rectangle.y + rectangle.height));

		for (y in minY...maxY) {
			for (x in minX...maxX) {
				result.push(getPixel32(x, y));
			}
		}

		return result;
	}

	public function getTexture(context:Dynamic = null):Dynamic {
		return __image;
	}

	public function histogram(hRect:Rectangle = null):Array<Array<Int>> {
		var targetRect = hRect == null ? rect : hRect;
		var result:Array<Array<Int>> = [];
		for (i in 0...4) {
			var channel:Array<Int> = [];
			for (j in 0...256) {
				channel.push(0);
			}
			result.push(channel);
		}

		if (!readable || targetRect == null) {
			return result;
		}

		var minX = Std.int(Math.max(0, targetRect.x));
		var minY = Std.int(Math.max(0, targetRect.y));
		var maxX = Std.int(Math.min(width, targetRect.x + targetRect.width));
		var maxY = Std.int(Math.min(height, targetRect.y + targetRect.height));

		for (y in minY...maxY) {
			for (x in minX...maxX) {
				var pixel = getPixel32(x, y);
				result[0][(pixel >> 24) & 0xFF]++;
				result[1][(pixel >> 16) & 0xFF]++;
				result[2][(pixel >> 8) & 0xFF]++;
				result[3][pixel & 0xFF]++;
			}
		}

		return result;
	}

	public function hitTest(firstPoint:Point, firstAlphaThreshold:Int, secondObject:Dynamic, secondBitmapDataPoint:Point = null,
			secondAlphaThreshold:Int = 1):Bool {
		if (!readable || firstPoint == null || secondObject == null) {
			return false;
		}

		if (Std.isOfType(secondObject, Point)) {
			var point:Point = cast secondObject;
			var x = Std.int(point.x - firstPoint.x);
			var y = Std.int(point.y - firstPoint.y);
			return ((__getPixel32(x, y) >> 24) & 0xFF) >= firstAlphaThreshold;
		}

		if (Std.isOfType(secondObject, Rectangle)) {
			var overlap = rect.intersection(cast secondObject);
			return !overlap.isEmpty();
		}

		if (Std.isOfType(secondObject, BitmapData)) {
			var other:BitmapData = cast secondObject;
			var otherPoint = secondBitmapDataPoint == null ? new Point() : secondBitmapDataPoint;
			for (y in 0...height) {
				for (x in 0...width) {
					var alphaA = (getPixel32(x, y) >> 24) & 0xFF;
					var otherX = Std.int(x + firstPoint.x - otherPoint.x);
					var otherY = Std.int(y + firstPoint.y - otherPoint.y);
					var alphaB = (other.getPixel32(otherX, otherY) >> 24) & 0xFF;
					if (alphaA >= firstAlphaThreshold && alphaB >= secondAlphaThreshold) {
						return true;
					}
				}
			}
		}

		return false;
	}

	public function lock():Void {}

	public static function loadFromBytes(bytes:ByteArray, rawAlpha:ByteArray = null):Future<BitmapData> {
		return Future.withValue(fromBytes(bytes, rawAlpha));
	}

	public static function loadFromFile(path:String):Future<BitmapData> {
		return Future.withValue(fromFile(path));
	}

	public function merge(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, redMultiplier:UInt, greenMultiplier:UInt, blueMultiplier:UInt,
			alphaMultiplier:UInt):Void {
		if (!readable || sourceBitmapData == null || sourceRect == null || destPoint == null) {
			return;
		}

		var minX = Std.int(Math.max(0, sourceRect.x));
		var minY = Std.int(Math.max(0, sourceRect.y));
		var maxX = Std.int(Math.min(sourceBitmapData.width, sourceRect.x + sourceRect.width));
		var maxY = Std.int(Math.min(sourceBitmapData.height, sourceRect.y + sourceRect.height));

		__invalidateImage();

		for (y in minY...maxY) {
			for (x in minX...maxX) {
				var destX = Std.int(destPoint.x + (x - minX));
				var destY = Std.int(destPoint.y + (y - minY));
				if (destX < 0 || destY < 0 || destX >= width || destY >= height) {
					continue;
				}

				var sourcePixel = sourceBitmapData.getPixel32(x, y);
				var destPixel = getPixel32(destX, destY);

				var srcA = (sourcePixel >> 24) & 0xFF;
				var srcR = (sourcePixel >> 16) & 0xFF;
				var srcG = (sourcePixel >> 8) & 0xFF;
				var srcB = sourcePixel & 0xFF;

				var dstA = (destPixel >> 24) & 0xFF;
				var dstR = (destPixel >> 16) & 0xFF;
				var dstG = (destPixel >> 8) & 0xFF;
				var dstB = destPixel & 0xFF;

				var outA = Std.int((srcA * alphaMultiplier + dstA * (256 - alphaMultiplier)) / 256);
				var outR = Std.int((srcR * redMultiplier + dstR * (256 - redMultiplier)) / 256);
				var outG = Std.int((srcG * greenMultiplier + dstG * (256 - greenMultiplier)) / 256);
				var outB = Std.int((srcB * blueMultiplier + dstB * (256 - blueMultiplier)) / 256);

				__setPixel32(destX, destY, (outA << 24) | (outR << 16) | (outG << 8) | outB);
			}
		}
	}

	public function noise(randomSeed:Int, low:Int = 0, high:Int = 255, channelOptions:Int = 7, grayScale:Bool = false):Void {
		if (!readable) {
			return;
		}

		var seed = randomSeed;
		__invalidateImage();

		for (i in 0...(width * height)) {
			seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF;
			var range = Std.int(Math.max(1, (high - low) + 1));
			var value = low + (seed % range);
			var alpha = (channelOptions & BitmapDataChannel.ALPHA) != 0 ? value : 0xFF;
			var red = (channelOptions & BitmapDataChannel.RED) != 0 ? value : 0;
			var green = grayScale ? red : ((channelOptions & BitmapDataChannel.GREEN) != 0 ? (Std.int((seed >> 8) % range) + low) : 0);
			var blue = grayScale ? red : ((channelOptions & BitmapDataChannel.BLUE) != 0 ? (Std.int((seed >> 16) % range) + low) : 0);
			__pixels[i] = (alpha << 24) | (__clampColor(red) << 16) | (__clampColor(green) << 8) | __clampColor(blue);
		}
	}

	public function paletteMap(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, redArray:Array<Int> = null, greenArray:Array<Int> = null,
			blueArray:Array<Int> = null, alphaArray:Array<Int> = null):Void {
		if (!readable || sourceBitmapData == null || sourceRect == null || destPoint == null) {
			return;
		}

		copyPixels(sourceBitmapData, sourceRect, destPoint);
	}

	public function perlinNoise(baseX:Float, baseY:Float, numOctaves:Int, randomSeed:Int, stitch:Bool = false, fractalNoise:Bool = false,
			channelOptions:Int = 7, grayScale:Bool = false, offsets:Array<Point> = null):Void {
		noise(randomSeed, 0, 255, channelOptions, grayScale);
	}

	public function scroll(dx:Int, dy:Int):Void {
		if (!readable || (dx == 0 && dy == 0)) {
			return;
		}

		var pixels = __pixels.copy();
		__invalidateImage();

		for (y in 0...height) {
			for (x in 0...width) {
				var sourceX = x - dx;
				var sourceY = y - dy;
				var index = (y * width) + x;
				__pixels[index] = (sourceX >= 0 && sourceY >= 0 && sourceX < width && sourceY < height) ? pixels[(sourceY * width) + sourceX] : 0;
			}
		}
	}

	public function setPixel(x:Int, y:Int, color:Int):Void {
		if (!readable) {
			return;
		}

		var value = transparent ? ((0xFF << 24) | (color & 0xFFFFFF)) : (0xFF000000 | (color & 0xFFFFFF));
		__invalidateImage();
		__setPixel32(x, y, value);
	}

	public function setPixel32(x:Int, y:Int, color:Int):Void {
		if (!readable) {
			return;
		}

		__invalidateImage();
		__setPixel32(x, y, transparent ? color : (0xFF000000 | (color & 0xFFFFFF)));
	}

	public function setPixels(rectangle:Rectangle, byteArray:ByteArray):Void {
		if (!readable || rectangle == null || byteArray == null) {
			return;
		}

		var minX = Std.int(Math.max(0, rectangle.x));
		var minY = Std.int(Math.max(0, rectangle.y));
		var maxX = Std.int(Math.min(width, rectangle.x + rectangle.width));
		var maxY = Std.int(Math.min(height, rectangle.y + rectangle.height));

		__invalidateImage();

		for (y in minY...maxY) {
			for (x in minX...maxX) {
				if (byteArray.bytesAvailable < 4) {
					return;
				}
				__setPixel32(x, y, byteArray.readInt());
			}
		}
	}

	public function setVector(rectangle:Rectangle, inputVector:Vector<UInt>):Void {
		if (!readable || rectangle == null || inputVector == null) {
			return;
		}

		var minX = Std.int(Math.max(0, rectangle.x));
		var minY = Std.int(Math.max(0, rectangle.y));
		var maxX = Std.int(Math.min(width, rectangle.x + rectangle.width));
		var maxY = Std.int(Math.min(height, rectangle.y + rectangle.height));
		var index = 0;

		__invalidateImage();

		for (y in minY...maxY) {
			for (x in minX...maxX) {
				if (index >= inputVector.length) {
					return;
				}
				__setPixel32(x, y, inputVector[index++]);
			}
		}
	}

	public function threshold(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, operation:String, threshold:Int, color:Int = 0,
			mask:Int = 0xFFFFFFFF, copySource:Bool = false):Int {
		if (!readable || sourceBitmapData == null || sourceRect == null || destPoint == null) {
			return 0;
		}

		var count = 0;
		var minX = Std.int(Math.max(0, sourceRect.x));
		var minY = Std.int(Math.max(0, sourceRect.y));
		var maxX = Std.int(Math.min(sourceBitmapData.width, sourceRect.x + sourceRect.width));
		var maxY = Std.int(Math.min(sourceBitmapData.height, sourceRect.y + sourceRect.height));
		__invalidateImage();

		for (y in minY...maxY) {
			for (x in minX...maxX) {
				var sourcePixel = sourceBitmapData.getPixel32(x, y);
				var value = sourcePixel & mask;
				var matched = switch (operation) {
					case "==": value == threshold;
					case "!=": value != threshold;
					case "<": value < threshold;
					case "<=": value <= threshold;
					case ">": value > threshold;
					case ">=": value >= threshold;
					default: false;
				}

				var destX = Std.int(destPoint.x + (x - minX));
				var destY = Std.int(destPoint.y + (y - minY));
				if (destX < 0 || destY < 0 || destX >= width || destY >= height) {
					continue;
				}

				if (matched) {
					__setPixel32(destX, destY, transparent ? color : (0xFF000000 | (color & 0xFFFFFF)));
					count++;
				} else if (copySource) {
					__setPixel32(destX, destY, sourcePixel);
				}
			}
		}

		return count;
	}

	public function unlock(changeRect:Rectangle = null):Void {}

	@:allow(openfl.display)
	function __forEachPixel(callback:Int->Int->Int->Void):Void {
		for (y in 0...height) {
			for (x in 0...width) {
				callback(x, y, __pixels[(y * width) + x]);
			}
		}
	}

	function __drawBitmapData(sourceBitmapData:BitmapData, matrix:Matrix, colorTransform:ColorTransform, clipRect:Rectangle):Void {
		if (sourceBitmapData == null) {
			return;
		}

		var transform = matrix == null ? new Matrix() : matrix.clone();
		var sourceRect = clipRect == null ? sourceBitmapData.rect : sourceBitmapData.rect.intersection(clipRect);
		var minX = Std.int(Math.max(0, sourceRect.x));
		var minY = Std.int(Math.max(0, sourceRect.y));
		var maxX = Std.int(Math.min(sourceBitmapData.width, sourceRect.x + sourceRect.width));
		var maxY = Std.int(Math.min(sourceBitmapData.height, sourceRect.y + sourceRect.height));

		for (y in minY...maxY) {
			for (x in minX...maxX) {
				var point = transform.transformPoint(new Point(x, y));
				var destX = Std.int(Math.round(point.x));
				var destY = Std.int(Math.round(point.y));
				var pixel = sourceBitmapData.getPixel32(x, y);
				if (colorTransform != null) {
					pixel = __applyColorTransformToPixel(pixel, colorTransform);
				}
				__copyPixel(destX, destY, pixel);
			}
		}
	}

	function __drawDisplayObject(object:openfl.display.DisplayObject, parentMatrix:Matrix, respectVisibility:Bool, colorTransform:ColorTransform,
			clipRect:Rectangle):Void {
		if (object == null) {
			return;
		}

		if (respectVisibility) {
			if (!object.visible || object.alpha <= 0) {
				return;
			}
		}

		var objectMatrix = __getObjectMatrix(object);
		var localClipRect:Rectangle = clipRect;
		if (object.scrollRect != null) {
			localClipRect = object.scrollRect.clone();
			objectMatrix = objectMatrix.clone();
			objectMatrix.tx -= object.scrollRect.x;
			objectMatrix.ty -= object.scrollRect.y;
		}

		if (object.scale9Grid != null && object.rotation == 0) {
			var graphics = Reflect.field(object, "graphics");
			if (graphics != null) {
				var scale9Matrix = parentMatrix.clone();
				scale9Matrix.concat(new Matrix(1, 0, 0, 1, objectMatrix.tx, objectMatrix.ty));
				__drawGraphicsCommandsScale9(graphics, object, scale9Matrix, colorTransform, localClipRect);
			}
		}

		var matrix = parentMatrix.clone();
		matrix.concat(objectMatrix);

		if (Std.isOfType(object, Bitmap)) {
			var bitmap:Bitmap = cast object;
			if (bitmap.bitmapData != null) {
				__drawBitmapData(bitmap.bitmapData, matrix, colorTransform, localClipRect);
			}
		}

		var graphics = Reflect.field(object, "graphics");
		if (graphics != null && object.scale9Grid == null) {
			__drawGraphicsCommands(graphics, matrix, colorTransform, localClipRect);
		}

		var children:Array<Dynamic> = cast Reflect.field(object, "__children");
		if (children != null) {
			for (child in children) {
				if (Std.isOfType(child, openfl.display.DisplayObject)) {
					__drawDisplayObject(cast child, matrix, true, colorTransform, localClipRect);
				}
			}
		}
	}

	function __drawGraphicsCommands(graphics:Dynamic, matrix:Matrix, colorTransform:ColorTransform, clipRect:Rectangle):Void {
		var commands:Array<Dynamic> = cast Reflect.field(graphics, "commands");
		if (commands == null) {
			return;
		}

		for (command in commands) {
			var pixel = __coerceColorToArgb(Reflect.field(command, "color"));
			if (colorTransform != null) {
				pixel = __applyColorTransformToPixel(pixel, colorTransform);
			}
			var rect = __clipLocalRect(Reflect.field(command, "x"), Reflect.field(command, "y"), Reflect.field(command, "width"), Reflect.field(command, "height"),
				clipRect);
			if (rect != null) {
				__fillTransformedRect(rect.x, rect.y, rect.width, rect.height, matrix, pixel, null);
			}
		}
	}

	function __drawGraphicsCommandsScale9(graphics:Dynamic, object:openfl.display.DisplayObject, matrix:Matrix, colorTransform:ColorTransform,
			clipRect:Rectangle):Void {
		var commands:Array<Dynamic> = cast Reflect.field(graphics, "commands");
		if (commands == null) {
			return;
		}

		var bounds:Rectangle = graphics.__getBounds();
		var grid = object.scale9Grid;
		if (bounds == null || grid == null || bounds.width <= 0 || bounds.height <= 0 || grid.width <= 0 || grid.height <= 0) {
			__drawGraphicsCommands(graphics, matrix, colorTransform, clipRect);
			return;
		}

		var left = grid.x - bounds.x;
		var right = bounds.right - grid.right;
		var top = grid.y - bounds.y;
		var bottom = bounds.bottom - grid.bottom;
		var centerWidth = grid.width;
		var centerHeight = grid.height;
		var targetWidth = object.width;
		var targetHeight = object.height;
		var targetCenterWidth = Math.max(0, targetWidth - left - right);
		var targetCenterHeight = Math.max(0, targetHeight - top - bottom);

		for (command in commands) {
			var rect = __clipLocalRect(Reflect.field(command, "x"), Reflect.field(command, "y"), Reflect.field(command, "width"), Reflect.field(command, "height"),
				clipRect);
			if (rect == null) {
				continue;
			}

			var mapped = __mapScale9Rect(rect, bounds, grid, left, right, top, bottom, centerWidth, centerHeight, targetWidth, targetHeight, targetCenterWidth,
				targetCenterHeight);
			if (mapped == null) {
				__drawGraphicsCommands(graphics, matrix, colorTransform, clipRect);
				return;
			}

			var pixel = __coerceColorToArgb(Reflect.field(command, "color"));
			if (colorTransform != null) {
				pixel = __applyColorTransformToPixel(pixel, colorTransform);
			}
			__fillTransformedRect(mapped.x, mapped.y, mapped.width, mapped.height, matrix, pixel, null);
		}
	}

	function __fillTransformedRect(x:Float, y:Float, width:Float, height:Float, matrix:Matrix, pixel:Int, clipRect:Rectangle):Void {
		var p1 = matrix.transformPoint(new Point(x, y));
		var p2 = matrix.transformPoint(new Point(x + width, y));
		var p3 = matrix.transformPoint(new Point(x + width, y + height));
		var p4 = matrix.transformPoint(new Point(x, y + height));

		var minX = Std.int(Math.floor(Math.min(Math.min(p1.x, p2.x), Math.min(p3.x, p4.x))));
		var maxX = Std.int(Math.ceil(Math.max(Math.max(p1.x, p2.x), Math.max(p3.x, p4.x))));
		var minY = Std.int(Math.floor(Math.min(Math.min(p1.y, p2.y), Math.min(p3.y, p4.y))));
		var maxY = Std.int(Math.ceil(Math.max(Math.max(p1.y, p2.y), Math.max(p3.y, p4.y))));

		if (clipRect != null) {
			minX = Std.int(Math.max(minX, clipRect.x));
			minY = Std.int(Math.max(minY, clipRect.y));
			maxX = Std.int(Math.min(maxX, clipRect.right));
			maxY = Std.int(Math.min(maxY, clipRect.bottom));
		}

		for (py in minY...maxY) {
			for (px in minX...maxX) {
				__copyPixel(px, py, pixel);
			}
		}
	}

	function __copyPixel(x:Int, y:Int, pixel:Int):Void {
		if (x < 0 || y < 0 || x >= width || y >= height) {
			return;
		}

		__invalidateImage();
		__setPixel32(x, y, transparent ? pixel : (0xFF000000 | (pixel & 0xFFFFFF)));
	}

	function __applyColorTransformToPixel(pixel:Int, colorTransform:ColorTransform):Int {
		var alpha = (pixel >> 24) & 0xFF;
		var red = (pixel >> 16) & 0xFF;
		var green = (pixel >> 8) & 0xFF;
		var blue = pixel & 0xFF;

		alpha = __clampColor((alpha * colorTransform.alphaMultiplier) + colorTransform.alphaOffset);
		red = __clampColor((red * colorTransform.redMultiplier) + colorTransform.redOffset);
		green = __clampColor((green * colorTransform.greenMultiplier) + colorTransform.greenOffset);
		blue = __clampColor((blue * colorTransform.blueMultiplier) + colorTransform.blueOffset);

		return (alpha << 24) | (red << 16) | (green << 8) | blue;
	}

	function __getPixel32(x:Int, y:Int):Int {
		if (x < 0 || y < 0 || x >= width || y >= height) {
			return 0;
		}
		return __pixels[(y * width) + x];
	}

	function __setPixel32(x:Int, y:Int, color:Int):Void {
		if (x < 0 || y < 0 || x >= width || y >= height) {
			return;
		}
		var normalized = __normalizePixelForStorage(color, transparent);
		__pixels[(y * width) + x] = normalized;
		fillColor = __toColor(normalized);
	}

	function __invalidateImage():Void {
		__image = null;
	}

	function __getObjectMatrix(object:Dynamic):Matrix {
		var radians = object.rotation * (Math.PI / 180);
		var cos = Math.cos(radians);
		var sin = Math.sin(radians);
		return new Matrix(cos * object.scaleX, sin * object.scaleX, -sin * object.scaleY, cos * object.scaleY, object.x, object.y);
	}

	function __clipLocalRect(x:Float, y:Float, width:Float, height:Float, clipRect:Rectangle):Rectangle {
		var rect = new Rectangle(x, y, width, height);
		if (clipRect == null) {
			return rect;
		}

		var clipped = rect.intersection(clipRect);
		return clipped.isEmpty() ? null : clipped;
	}

	function __mapScale9Rect(rect:Rectangle, bounds:Rectangle, grid:Rectangle, left:Float, right:Float, top:Float, bottom:Float, centerWidth:Float,
			centerHeight:Float, targetWidth:Float, targetHeight:Float, targetCenterWidth:Float, targetCenterHeight:Float):Rectangle {
		var mappedX = __mapScale9Axis(rect.x, rect.width, bounds.x, grid.x, grid.right, left, right, centerWidth, targetWidth, targetCenterWidth);
		var mappedY = __mapScale9Axis(rect.y, rect.height, bounds.y, grid.y, grid.bottom, top, bottom, centerHeight, targetHeight, targetCenterHeight);
		if (mappedX == null || mappedY == null) {
			return null;
		}

		return new Rectangle(mappedX.position, mappedY.position, mappedX.size, mappedY.size);
	}

	function __mapScale9Axis(position:Float, size:Float, boundsStart:Float, gridStart:Float, gridEnd:Float, fixedStart:Float, fixedEnd:Float, centerSize:Float,
			targetSize:Float, targetCenterSize:Float):{ position:Float, size:Float } {
		var end = position + size;

		if (end <= gridStart) {
			return { position: position - boundsStart, size: size };
		}

		if (position >= gridEnd) {
			return { position: targetSize - fixedEnd + (position - gridEnd), size: size };
		}

		if (position >= gridStart && end <= gridEnd) {
			if (centerSize == 0) {
				return { position: fixedStart, size: 0 };
			}

			return {
				position: fixedStart + ((position - gridStart) * targetCenterSize / centerSize),
				size: size * targetCenterSize / centerSize
			};
		}

		return null;
	}

	function __getFilterPadding(filter:BitmapFilter):Point {
		if (filter == null) {
			return new Point();
		}

		var blurX = Reflect.hasField(filter, "blurX") ? Reflect.field(filter, "blurX") : 0.0;
		var blurY = Reflect.hasField(filter, "blurY") ? Reflect.field(filter, "blurY") : 0.0;
		return new Point(Math.ceil(blurX / 2), Math.ceil(blurY / 2));
	}

	static function __channelShift(channel:BitmapDataChannel):Int {
		return switch (channel) {
			case ALPHA: 24;
			case RED: 16;
			case GREEN: 8;
			case BLUE: 0;
			default: 0;
		};
	}

	static function __readChannel(pixel:Int, channel:BitmapDataChannel):Int {
		return (pixel >> __channelShift(channel)) & 0xFF;
	}

	static function __writeChannel(pixel:Int, channel:BitmapDataChannel, value:Int, transparent:Bool):Int {
		var shift = __channelShift(channel);
		var masked = pixel & ~(0xFF << shift);
		var result = masked | ((__clampColor(value)) << shift);
		return transparent ? result : (0xFF000000 | (result & 0xFFFFFF));
	}

	static function __clampColor(value:Float):Int {
		return Std.int(Math.max(0, Math.min(255, value)));
	}

	static function __coerceColorToArgb(value:Dynamic):Int {
		if (value == null) {
			return 0;
		}

		var color:Int = cast value;
		if ((color & 0xFF000000) == 0) {
			return 0xFF000000 | (color & 0xFFFFFF);
		}
		return color;
	}

	static function __toColor(color:Int):kha.Color {
		return kha.Color.fromBytes((color >> 16) & 0xFF, (color >> 8) & 0xFF, color & 0xFF, (color >> 24) & 0xFF);
	}

	static function __normalizePixelForStorage(color:Int, transparent:Bool):Int {
		if (!transparent) {
			return 0xFF000000 | (color & 0xFFFFFF);
		}

		return ((color >> 24) & 0xFF) == 0 ? 0 : color;
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

	static function __detectEncodedImageFormat(bytes:ByteArray):String {
		if (bytes == null || bytes.length < 4) {
			return null;
		}

		var raw:haxe.io.Bytes = bytes;
		if (raw.get(0) == 0x89 && raw.get(1) == 0x50 && raw.get(2) == 0x4E && raw.get(3) == 0x47) {
			return "png";
		}
		if (raw.get(0) == 0xFF && raw.get(1) == 0xD8) {
			return "jpg";
		}
		if (raw.get(0) == 0x47 && raw.get(1) == 0x49 && raw.get(2) == 0x46) {
			return "gif";
		}
		if ((raw.get(0) == "h".code || raw.get(0) == "H".code) && (raw.get(1) == "d".code || raw.get(1) == "D".code)
			&& (raw.get(2) == "r".code || raw.get(2) == "R".code)) {
			return "hdr";
		}

		return null;
	}

	@:noCompletion private function __copyFrom(source:BitmapData):Void {
		if (source == null) {
			return;
		}

		width = source.width;
		height = source.height;
		transparent = source.transparent;
		rect = new Rectangle(0, 0, width, height);
		fillColor = source.fillColor;
		readable = source.readable;
		__pixels = source.__pixels.copy();
		__image = source.__image;
		image = source.image;
	}

	@:noCompletion private function __fromBytes(bytes:ByteArray, rawAlpha:ByteArray = null):Void {
		__copyFrom(BitmapData.fromBytes(bytes, rawAlpha));
	}

	@:noCompletion private function __fromFile(path:String):Void {
		__copyFrom(BitmapData.fromFile(path));
	}

	@:noCompletion private function __fromImage(image:Dynamic):Void {
		__copyFrom(BitmapData.fromImage(image, transparent));
	}

	@:noCompletion private inline function __loadFromBase64(base64:String, type:String):Future<BitmapData> {
		__copyFrom(BitmapData.fromBase64(base64, type));
		return Future.withValue(this);
	}

	@:noCompletion private inline function __loadFromBytes(bytes:ByteArray, rawAlpha:ByteArray = null):Future<BitmapData> {
		__copyFrom(BitmapData.fromBytes(bytes, rawAlpha));
		return Future.withValue(this);
	}

	@:allow(openfl.utils.Assets)
	static function __fromKhaImage(image:kha.Image, assetId:String = null):BitmapData {
		if (image == null) {
			return null;
		}

		__trace('BitmapData.__fromKhaImage start size=' + image.width + 'x' + image.height);
		var bitmapData = new BitmapData(image.width, image.height, true, 0x00000000);
		bitmapData.__image = image;

		__trace('BitmapData.__fromKhaImage before getPixels');
		var pixels = image.getPixels();
		__trace('BitmapData.__fromKhaImage after getPixels null=' + (pixels == null));
		if (pixels != null) {
			bitmapData.__pixels = [];
			for (i in 0...(image.width * image.height)) {
				var offset = i * 4;
				var red = pixels.get(offset);
				var green = pixels.get(offset + 1);
				var blue = pixels.get(offset + 2);
				var alpha = pixels.get(offset + 3);
				bitmapData.__pixels.push((alpha << 24) | (red << 16) | (green << 8) | blue);
			}
		} else {
			bitmapData.__pixels = [];
			for (y in 0...image.height) {
				for (x in 0...image.width) {
					var raw:Int = cast image.at(x, y);
					var alpha = (raw >> 24) & 0xFF;
					var red = raw & 0xFF;
					var green = (raw >> 8) & 0xFF;
					var blue = (raw >> 16) & 0xFF;
					bitmapData.__pixels.push((alpha << 24) | (red << 16) | (green << 8) | blue);
				}
			}
		}

		return bitmapData;
	}
}
