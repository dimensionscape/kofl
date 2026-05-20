package openfl._internal.kha.debug;

import kha.Color;
import kha.Image;
#if (cpp && windows)
import kha.BackbufferCapture;
#end
import openfl.display.Stage;

#if sys
import haxe.io.Bytes;
import sys.io.File;
#end

class FrameCapture {
	static var __configured = false;
	static var __enabled = false;
	static var __completed = false;
	static var __frameIndex = 0;
	static var __targetFrame = 0;
	static var __outputPath:String = null;

	public static function captureIfRequested(stage:Stage, width:Int, height:Int, clearColor:Color):Void {
		__configure();

		if (!__enabled || __completed) {
			return;
		}

		if (__frameIndex != __targetFrame) {
			__frameIndex++;
			return;
		}

		__completed = true;

		#if sys
		var pixels = __capturePixels(stage, width, height, clearColor);
		if (pixels != null) {
			File.saveBytes(__outputPath, __encodeBmp(width, height, pixels));
		}
		#end
	}

	static function __configure():Void {
		if (__configured) {
			return;
		}

		__configured = true;

		#if sys
		__outputPath = Sys.getEnv("KOFL_CAPTURE_FRAME_PATH");
		__enabled = __outputPath != null && __outputPath != "";

		var rawTargetFrame = Sys.getEnv("KOFL_CAPTURE_FRAME_INDEX");
		if (rawTargetFrame != null && rawTargetFrame != "") {
			var parsed = Std.parseInt(rawTargetFrame);
			if (parsed != null && parsed >= 0) {
				__targetFrame = parsed;
			}
		}
		#end
	}

	#if sys
	static function __capturePixels(stage:Stage, width:Int, height:Int, clearColor:Color):Bytes {
		#if (cpp && windows)
		var pixels = BackbufferCapture.capture();
		if (pixels != null) {
			return pixels;
		}
		#end

		var image = Image.createRenderTarget(width, height);
		var g2 = image.g2;
		g2.begin(true, clearColor);
		stage.__render(g2, 0, 0);
		g2.end();

		var pixels = image.getPixels();
		image.unload();
		return pixels;
	}

	static function __encodeBmp(width:Int, height:Int, pixels:Bytes):Bytes {
		var headerSize = 54;
		var rowSize = width * 3;
		var paddedRowSize = (rowSize + 3) & ~3;
		var imageSize = paddedRowSize * height;
		var output = Bytes.alloc(headerSize + imageSize);

		output.set(0, "B".code);
		output.set(1, "M".code);
		__writeInt32LE(output, 2, headerSize + imageSize);
		__writeInt32LE(output, 10, headerSize);
		__writeInt32LE(output, 14, 40);
		__writeInt32LE(output, 18, width);
		__writeInt32LE(output, 22, height);
		__writeInt16LE(output, 26, 1);
		__writeInt16LE(output, 28, 24);
		__writeInt32LE(output, 30, 0);
		__writeInt32LE(output, 34, imageSize);
		__writeInt32LE(output, 38, 2835);
		__writeInt32LE(output, 42, 2835);
		__writeInt32LE(output, 46, 0);
		__writeInt32LE(output, 50, 0);

		var destination = headerSize;

		for (row in 0...height) {
			var sourceRow = (height - 1 - row) * width * 4;
			for (column in 0...width) {
				var source = sourceRow + (column * 4);
				output.set(destination, pixels.get(source));
				output.set(destination + 1, pixels.get(source + 1));
				output.set(destination + 2, pixels.get(source + 2));
				destination += 3;
			}

			while ((destination - headerSize) % paddedRowSize != 0) {
				output.set(destination, 0);
				destination++;
			}
		}

		return output;
	}

	static function __writeInt16LE(bytes:Bytes, position:Int, value:Int):Void {
		bytes.set(position, value & 0xFF);
		bytes.set(position + 1, (value >>> 8) & 0xFF);
	}

	static function __writeInt32LE(bytes:Bytes, position:Int, value:Int):Void {
		bytes.set(position, value & 0xFF);
		bytes.set(position + 1, (value >>> 8) & 0xFF);
		bytes.set(position + 2, (value >>> 16) & 0xFF);
		bytes.set(position + 3, (value >>> 24) & 0xFF);
	}
	#end
}
