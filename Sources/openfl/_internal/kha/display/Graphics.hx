package openfl._internal.kha.display;

import kha.Color;
import kha.graphics2.Graphics as KhaGraphics;
import openfl.display.CapsStyle;
import openfl.display.GraphicsBitmapFill;
import openfl.display.GraphicsEndFill;
import openfl.display.GraphicsGradientFill;
import openfl.display.GraphicsPath;
import openfl.display.GraphicsPathCommand;
import openfl.display.GraphicsPathWinding;
import openfl.display.GraphicsSolidFill;
import openfl.display.GraphicsStroke;
import openfl.display.IGraphicsData;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.SpreadMethod;
import openfl.display.InterpolationMethod;
import openfl.display.TriangleCulling;
import openfl.geom.Matrix;
import openfl.Vector;

private typedef RectCommand = {
	var color:Color;
	var x:Float;
	var y:Float;
	var width:Float;
	var height:Float;
}

class Graphics {
	public var __boundsHeight(default, null):Float = 0;
	public var __boundsWidth(default, null):Float = 0;
	public var __boundsX(default, null):Float = 0;
	public var __boundsY(default, null):Float = 0;
	var commands:Array<RectCommand> = [];
	var fillColor:Color = Color.White;
	var cursorX:Float = 0;
	var cursorY:Float = 0;
	var lineColor:Color = Color.White;
	var lineThickness:Float = 0;

	public function new() {}

	public function clear():Void {
		commands = [];
		__boundsWidth = 0;
		__boundsHeight = 0;
		__boundsX = 0;
		__boundsY = 0;
		cursorX = 0;
		cursorY = 0;
		lineThickness = 0;
	}

	public function copyFrom(sourceGraphics:Graphics):Void {
		if (sourceGraphics == null) {
			clear();
			return;
		}

		commands = sourceGraphics.commands.copy();
		fillColor = sourceGraphics.fillColor;
		cursorX = sourceGraphics.cursorX;
		cursorY = sourceGraphics.cursorY;
		lineColor = sourceGraphics.lineColor;
		lineThickness = sourceGraphics.lineThickness;
		__boundsX = sourceGraphics.__boundsX;
		__boundsY = sourceGraphics.__boundsY;
		__boundsWidth = sourceGraphics.__boundsWidth;
		__boundsHeight = sourceGraphics.__boundsHeight;
	}

	public function beginFill(color:Dynamic, alpha:Float = 1.0):Void {
		if (Std.isOfType(color, Int)) {
			var colorValue:Int = color;
			var a = Std.int(alpha * 255);
			fillColor = Color.fromBytes((colorValue >> 16) & 0xFF, (colorValue >> 8) & 0xFF, colorValue & 0xFF, a);
		}
		else {
			fillColor = cast color;
		}
	}

	public function beginBitmapFill(bitmap:Dynamic, matrix:Matrix = null, repeat:Bool = true, smooth:Bool = false):Void {}

	public function beginGradientFill(type:Dynamic, colors:Array<Int>, alphas:Array<Float>, ratios:Array<Int>, matrix:Matrix = null,
		spreadMethod:SpreadMethod = null, interpolationMethod:InterpolationMethod = null, focalPointRatio:Float = 0):Void
	{
		if (colors != null && colors.length > 0) {
			beginFill(colors[0], alphas != null && alphas.length > 0 ? alphas[0] : 1.0);
		}
	}

	public function endFill():Void {}

	public function drawRect(x:Float, y:Float, width:Float, height:Float):Void {
		commands.push({
			color: fillColor,
			x: x,
			y: y,
			width: width,
			height: height
		});
		__expandBounds(x, y, width, height);
	}

	public function drawCircle(x:Float, y:Float, radius:Float):Void {
		drawRect(x - radius, y - radius, radius * 2, radius * 2);
	}

	public function drawEllipse(x:Float, y:Float, width:Float, height:Float):Void {
		drawRect(x, y, width, height);
	}

	public function drawGraphicsData(graphicsData:Vector<IGraphicsData>):Void {
		if (graphicsData == null) {
			return;
		}

		for (item in graphicsData) {
			if (Std.isOfType(item, GraphicsSolidFill)) {
				var solidFill:GraphicsSolidFill = cast item;
				beginFill(solidFill.color, solidFill.alpha);
			}
			else if (Std.isOfType(item, GraphicsEndFill)) {
				endFill();
			}
			else if (Std.isOfType(item, GraphicsPath)) {
				var path:GraphicsPath = cast item;
				drawPath(path.commands, path.data, path.winding);
			}
			else if (Std.isOfType(item, GraphicsStroke)) {
				var stroke:GraphicsStroke = cast item;
				lineStyle(stroke.thickness, stroke.fill != null && Std.isOfType(stroke.fill, GraphicsSolidFill) ? cast(stroke.fill, GraphicsSolidFill).color : 0xFFFFFF,
					stroke.fill != null && Std.isOfType(stroke.fill, GraphicsSolidFill) ? cast(stroke.fill, GraphicsSolidFill).alpha : 1.0);
			}
		}
	}

	public function drawPath(commands:Vector<Int>, data:Vector<Float>, winding:GraphicsPathWinding = null):Void {
		if (commands == null || data == null) {
			return;
		}

		var dataIndex = 0;
		for (command in commands) {
			switch (command) {
				case GraphicsPathCommand.MOVE_TO:
					moveTo(data[dataIndex], data[dataIndex + 1]);
					dataIndex += 2;
				case GraphicsPathCommand.LINE_TO:
					lineTo(data[dataIndex], data[dataIndex + 1]);
					dataIndex += 2;
				case GraphicsPathCommand.CURVE_TO:
					curveTo(data[dataIndex], data[dataIndex + 1], data[dataIndex + 2], data[dataIndex + 3]);
					dataIndex += 4;
				case GraphicsPathCommand.WIDE_MOVE_TO:
					moveTo(data[dataIndex + 2], data[dataIndex + 3]);
					dataIndex += 4;
				case GraphicsPathCommand.WIDE_LINE_TO:
					lineTo(data[dataIndex + 2], data[dataIndex + 3]);
					dataIndex += 4;
				case GraphicsPathCommand.NO_OP:
				default:
			}
		}
	}

	public function drawRoundRect(x:Float, y:Float, width:Float, height:Float, ellipseWidth:Float, ellipseHeight:Float = -1):Void {
		drawRect(x, y, width, height);
	}

	public function drawRoundRectComplex(x:Float, y:Float, width:Float, height:Float, topLeftRadius:Float, topRightRadius:Float, bottomLeftRadius:Float,
		bottomRightRadius:Float):Void
	{
		drawRect(x, y, width, height);
	}

	public function drawTriangles(vertices:Vector<Float>, indices:Vector<Int> = null, uvtData:Vector<Float> = null, culling:TriangleCulling = null):Void {
		if (vertices == null || vertices.length < 2) {
			return;
		}

		var minX = vertices[0];
		var maxX = vertices[0];
		var minY = vertices[1];
		var maxY = vertices[1];

		for (i in 0...Std.int(vertices.length / 2)) {
			var x = vertices[i * 2];
			var y = vertices[i * 2 + 1];
			minX = Math.min(minX, x);
			maxX = Math.max(maxX, x);
			minY = Math.min(minY, y);
			maxY = Math.max(maxY, y);
		}

		drawRect(minX, minY, maxX - minX, maxY - minY);
	}

	public function lineBitmapStyle(bitmap:Dynamic, matrix:Matrix = null, repeat:Bool = true, smooth:Bool = false):Void {}

	public function lineGradientStyle(type:Dynamic, colors:Array<Int>, alphas:Array<Float>, ratios:Array<Int>, matrix:Matrix = null,
		spreadMethod:SpreadMethod = null, interpolationMethod:InterpolationMethod = null, focalPointRatio:Float = 0):Void
	{
		if (colors != null && colors.length > 0) {
			lineStyle(lineThickness == 0 ? 1 : lineThickness, colors[0], alphas != null && alphas.length > 0 ? alphas[0] : 1.0);
		}
	}

	public function lineStyle(thickness:Null<Float> = null, color:Int = 0, alpha:Float = 1.0, pixelHinting:Bool = false, scaleMode:LineScaleMode = null,
		caps:CapsStyle = null, joints:JointStyle = null, miterLimit:Float = 3):Void
	{
		lineThickness = thickness == null ? 0 : thickness;
		var a = Std.int(alpha * 255);
		lineColor = Color.fromBytes((color >> 16) & 0xFF, (color >> 8) & 0xFF, color & 0xFF, a);
	}

	public function lineTo(x:Float, y:Float):Void {
		var minX = Math.min(cursorX, x);
		var minY = Math.min(cursorY, y);
		var width = Math.max(Math.abs(x - cursorX), lineThickness == 0 ? 1 : lineThickness);
		var height = Math.max(Math.abs(y - cursorY), lineThickness == 0 ? 1 : lineThickness);
		commands.push({
			color: lineColor,
			x: minX,
			y: minY,
			width: width,
			height: height
		});
		__expandBounds(minX, minY, width, height);
		cursorX = x;
		cursorY = y;
	}

	public function moveTo(x:Float, y:Float):Void {
		cursorX = x;
		cursorY = y;
	}

	public function curveTo(controlX:Float, controlY:Float, anchorX:Float, anchorY:Float):Void {
		var minX = Math.min(Math.min(cursorX, controlX), anchorX);
		var minY = Math.min(Math.min(cursorY, controlY), anchorY);
		var maxX = Math.max(Math.max(cursorX, controlX), anchorX);
		var maxY = Math.max(Math.max(cursorY, controlY), anchorY);
		commands.push({
			color: lineColor,
			x: minX,
			y: minY,
			width: Math.max(maxX - minX, lineThickness == 0 ? 1 : lineThickness),
			height: Math.max(maxY - minY, lineThickness == 0 ? 1 : lineThickness)
		});
		__expandBounds(minX, minY, Math.max(maxX - minX, lineThickness == 0 ? 1 : lineThickness), Math.max(maxY - minY, lineThickness == 0 ? 1 : lineThickness));
		cursorX = anchorX;
		cursorY = anchorY;
	}

	public function __getBounds():openfl.geom.Rectangle {
		return new openfl.geom.Rectangle(__boundsX, __boundsY, __boundsWidth, __boundsHeight);
	}

	function __expandBounds(x:Float, y:Float, width:Float, height:Float):Void {
		if (commands.length == 1) {
			__boundsX = x;
			__boundsY = y;
			__boundsWidth = width;
			__boundsHeight = height;
			return;
		}

		var minX = Math.min(__boundsX, x);
		var minY = Math.min(__boundsY, y);
		var maxX = Math.max(__boundsX + __boundsWidth, x + width);
		var maxY = Math.max(__boundsY + __boundsHeight, y + height);
		__boundsX = minX;
		__boundsY = minY;
		__boundsWidth = maxX - minX;
		__boundsHeight = maxY - minY;
	}

	public function __render(g2:KhaGraphics, offsetX:Float, offsetY:Float):Void {
		for (command in commands) {
			g2.color = command.color;
			g2.fillRect(offsetX + command.x, offsetY + command.y, command.width, command.height);
		}

		g2.color = Color.White;
	}
}
