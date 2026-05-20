package openfl.display;

import kha.graphics2.Graphics as KhaGraphics;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class DisplayObjectContainer extends InteractiveObject {
	static var __instanceCount = 0;

	public var mouseChildren:Bool;
	public var numChildren(get, never):Int;
	public var tabChildren(get, set):Bool;
	@:allow(openfl)
	public var __loaderInfo:LoaderInfo;
	@:allow(openfl.display)
	var __children:Array<DisplayObject> = [];

	var __tabChildren = true;

	public function new() {
		super();
		mouseChildren = true;
		name = "instance" + __instanceCount++;
	}

	public function addChild(child:DisplayObject):DisplayObject {
		return addChildAt(child, __children.length);
	}

	public function addChildAt(child:DisplayObject, index:Int):DisplayObject {
		if (child == null) {
			return child;
		}

		if (child == this) {
			throw "An object cannot be added as a child of itself";
		}

		if (index < 0 || index > __children.length) {
			throw "Invalid index position " + index;
		}

		var currentIndex = __children.indexOf(child);
		if (currentIndex != -1) {
			if (currentIndex == index) {
				return child;
			}

			__children.splice(currentIndex, 1);
			__children.insert(index, child);
			return child;
		}

		if (contains(child) && child != this) {
			// already in subtree, but not necessarily direct parent
		}

		if (__wouldCreateCycle(child)) {
			throw "An object cannot be added as a child to one of its children";
		}

		if (child.parent != null) {
			if (Std.isOfType(child.parent, DisplayObjectContainer)) {
				cast(child.parent, DisplayObjectContainer).removeChild(child);
			} else {
				var removeChild = Reflect.field(child.parent, "removeChild");
				if (removeChild != null) {
					Reflect.callMethod(child.parent, removeChild, [child]);
				}
			}
		}

		__children.insert(index, child);
		child.setParent(this);
		child.dispatchEvent(new Event(Event.ADDED));

		if (stage != null) {
			child.__broadcastAddedToStage();
			__broadcastChildAddedToStage(child);
		}

		return child;
	}

	public function areInaccessibleObjectsUnderPoint(point:Point):Bool {
		return false;
	}

	public function contains(child:DisplayObject):Bool {
		if (child == this) {
			return true;
		}

		for (candidate in __children) {
			if (candidate == child) {
				return true;
			}

			if (Std.isOfType(candidate, DisplayObjectContainer) && cast(candidate, DisplayObjectContainer).contains(child)) {
				return true;
			}
		}

		return false;
	}

	override public function getBounds(targetCoordinateSpace:DisplayObject):Rectangle {
		var localBounds = __getLocalBounds();
		if (targetCoordinateSpace == this || targetCoordinateSpace == null) {
			return localBounds;
		}

		var world = __getWorldMatrix();
		var target = targetCoordinateSpace.__getWorldMatrix().clone();
		target.invert();

		var result = new Rectangle();
		__transformRectLocal(localBounds, world, result);
		__transformRectLocal(result, target, result);
		return result;
	}

	public function getChildAt(index:Int):DisplayObject {
		if (index < 0 || index >= __children.length) {
			throw "Invalid index position " + index;
		}

		return __children[index];
	}

	public function getChildByName(name:String):DisplayObject {
		for (child in __children) {
			if (child.name == name) {
				return child;
			}
		}

		return null;
	}

	public function getChildIndex(child:DisplayObject):Int {
		return __children.indexOf(child);
	}

	public function getObjectsUnderPoint(point:Point):Array<DisplayObject> {
		var matches:Array<DisplayObject> = [];
		__collectObjectsUnderPoint(point, matches);
		return matches;
	}

	override public function getRect(targetCoordinateSpace:DisplayObject):Rectangle {
		return getBounds(targetCoordinateSpace);
	}

	override public function globalToLocal(pos:Point):Point {
		var matrix = __getWorldMatrix().clone();
		matrix.invert();
		return matrix.transformPoint(pos);
	}

	override public function hitTestObject(obj:DisplayObject):Bool {
		return getBounds(null).intersects(obj.getBounds(null));
	}

	override public function hitTestPoint(x:Float, y:Float, shapeFlag:Bool = false):Bool {
		var bounds = getBounds(null);
		if (shapeFlag) {
			return x > bounds.x && y > bounds.y && x < bounds.right && y < bounds.bottom;
		}
		return bounds.contains(x, y);
	}

	override public function localToGlobal(point:Point):Point {
		return __getWorldMatrix().transformPoint(point);
	}

	public function removeChild(child:DisplayObject):DisplayObject {
		var index = __children.indexOf(child);
		if (index >= 0) {
			return removeChildAt(index);
		}

		return child;
	}

	public function removeChildAt(index:Int):DisplayObject {
		if (index < 0 || index >= __children.length) {
			throw "Invalid index position " + index;
		}

		var child = __children[index];
		if (child == null) {
			return child;
		}

		__children.splice(index, 1);
		if (stage != null) {
			child.__broadcastRemovedFromStage();
			__broadcastChildRemovedFromStage(child);
		}
		child.dispatchEvent(new Event(Event.REMOVED));
		child.setParent(null);

		return child;
	}

	public function removeChildren(beginIndex:Int = 0, endIndex:Int = 0x7FFFFFFF):Void {
		if (__children.length == 0) {
			return;
		}

		if (endIndex == 0x7FFFFFFF) {
			endIndex = __children.length - 1;
		}

		if (beginIndex > __children.length - 1) {
			return;
		}

		if (endIndex < beginIndex || beginIndex < 0 || endIndex > __children.length - 1) {
			throw new RangeError("The supplied index is out of bounds.");
		}

		var removals = endIndex - beginIndex;
		while (removals-- >= 0) {
			removeChildAt(beginIndex);
		}
	}

	public function setChildIndex(child:DisplayObject, index:Int):Void {
		var currentIndex = __children.indexOf(child);
		if (currentIndex == -1) {
			throw "The supplied DisplayObject must be a child of the caller";
		}

		if (index < 0 || index >= __children.length) {
			throw "Invalid index position " + index;
		}

		if (currentIndex == index) {
			return;
		}

		__children.splice(currentIndex, 1);
		__children.insert(index, child);
	}

	public function stopAllMovieClips():Void {}

	public function swapChildren(child1:DisplayObject, child2:DisplayObject):Void {
		var index1 = __children.indexOf(child1);
		var index2 = __children.indexOf(child2);

		if (index1 == -1 || index2 == -1) {
			throw "Both supplied DisplayObjects must be children of the caller";
		}

		swapChildrenAt(index1, index2);
	}

	public function swapChildrenAt(index1:Int, index2:Int):Void {
		if (index1 < 0 || index1 >= __children.length || index2 < 0 || index2 >= __children.length) {
			throw "Invalid index position";
		}

		if (index1 == index2) {
			return;
		}

		var child1 = __children[index1];
		__children[index1] = __children[index2];
		__children[index2] = child1;
	}

	#if !openfl_strict
	override public function requestSoftKeyboard():Bool {
		return false;
	}
	#end

	override public function __render(g2:KhaGraphics, offsetX:Float, offsetY:Float):Void {
		if (!__beginRender(g2, offsetX, offsetY)) {
			return;
		}

		for (child in __children) {
			child.__render(g2, 0, 0);
		}

		__endRender(g2);
	}

	override public function __update(deltaTime:Float):Void {
		for (child in __children) {
			child.__update(deltaTime);
		}
	}

	override public function __broadcastEnterFrame():Void {
		super.__broadcastEnterFrame();
		for (child in __children) {
			child.__broadcastEnterFrame();
		}
	}

	@:allow(openfl._internal.kha.display)
	function __broadcastAddedToStageToChildren():Void {
		for (child in __children) {
			child.__broadcastAddedToStage();
			__broadcastChildAddedToStage(child);
		}
	}

	@:allow(openfl._internal.kha.display)
	function __broadcastRemovedFromStageToChildren():Void {
		for (child in __children) {
			child.__broadcastRemovedFromStage();
			__broadcastChildRemovedFromStage(child);
		}
	}

	@:allow(openfl.display)
	override function __getLocalBounds():Rectangle {
		var result = new Rectangle();
		var initialized = false;
		var minX = 0.0;
		var minY = 0.0;
		var maxX = 0.0;
		var maxY = 0.0;

		for (child in __children) {
			var childBounds = child.__getLocalBounds();
			var transformed = new Rectangle();
			__transformRectLocal(childBounds, child.__getLocalMatrix(), transformed);

			if (!initialized) {
				minX = transformed.x;
				minY = transformed.y;
				maxX = transformed.right;
				maxY = transformed.bottom;
				initialized = true;
			} else {
				minX = Math.min(minX, transformed.x);
				minY = Math.min(minY, transformed.y);
				maxX = Math.max(maxX, transformed.right);
				maxY = Math.max(maxY, transformed.bottom);
			}
		}

		if (!initialized) {
			result.setEmpty();
		} else {
			result.setTo(__normalizeZero(minX), __normalizeZero(minY), __normalizeZero(maxX - minX), __normalizeZero(maxY - minY));
		}

		return result;
	}

	function __broadcastChildAddedToStage(child:DisplayObject):Void {
		var method = Reflect.field(child, "__broadcastAddedToStageToChildren");
		if (method != null) {
			Reflect.callMethod(child, method, []);
		}
	}

	function __broadcastChildRemovedFromStage(child:DisplayObject):Void {
		var method = Reflect.field(child, "__broadcastRemovedFromStageToChildren");
		if (method != null) {
			Reflect.callMethod(child, method, []);
		}
	}

	function __collectObjectsUnderPoint(point:Point, matches:Array<DisplayObject>):Void {
		var index = __children.length;
		while (index-- > 0) {
			var child = __children[index];

			if (child == null || !child.visible || child.alpha <= 0) {
				continue;
			}

			if (Std.isOfType(child, DisplayObjectContainer)) {
				cast(child, DisplayObjectContainer).__collectObjectsUnderPoint(point, matches);
			}

			if (child.hitTestPoint(point.x, point.y, true)) {
				matches.push(child);
			}
		}
	}

	function __transformRectLocal(source:Rectangle, matrix:Matrix, output:Rectangle):Void {
		var p1 = matrix.transformPoint(new Point(source.x, source.y));
		var p2 = matrix.transformPoint(new Point(source.right, source.y));
		var p3 = matrix.transformPoint(new Point(source.right, source.bottom));
		var p4 = matrix.transformPoint(new Point(source.x, source.bottom));

		var minX = Math.min(Math.min(p1.x, p2.x), Math.min(p3.x, p4.x));
		var maxX = Math.max(Math.max(p1.x, p2.x), Math.max(p3.x, p4.x));
		var minY = Math.min(Math.min(p1.y, p2.y), Math.min(p3.y, p4.y));
		var maxY = Math.max(Math.max(p1.y, p2.y), Math.max(p3.y, p4.y));
		output.setTo(__normalizeZero(minX), __normalizeZero(minY), __normalizeZero(maxX - minX), __normalizeZero(maxY - minY));
	}

	function __wouldCreateCycle(child:DisplayObject):Bool {
		var current:openfl._internal.kha.display.DisplayObject = this;
		while (current != null) {
			if (current == child) {
				return true;
			}
			current = current.parent;
		}
		return false;
	}

	function get_numChildren():Int {
		return __children.length;
	}

	function get_tabChildren():Bool {
		return __tabChildren;
	}

	function set_tabChildren(value:Bool):Bool {
		if (__tabChildren != value) {
			__tabChildren = value;
			dispatchEvent(new Event(Event.TAB_CHILDREN_CHANGE, true, false));
		}
		return value;
	}

	static function __normalizeZero(value:Float):Float {
		return Math.abs(value) < 1e-10 ? 0.0 : value;
	}
}
