package openfl._internal.kha.display;

import kha.graphics2.Graphics;
import openfl.events.Event;

class DisplayObjectContainer extends DisplayObject {
	public var numChildren(get, never):Int;
	@:allow(openfl.display)
	var __children:Array<DisplayObject> = [];

	public function new() {
		super();
	}

	function get_numChildren():Int {
		return __children.length;
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

		if (__childContainsParent(child, this)) {
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

	public function contains(child:DisplayObject):Bool {
		if (child == null) {
			return false;
		}

		if (__children.indexOf(child) != -1) {
			return true;
		}

		for (candidate in __children) {
			if (__childContainsParent(candidate, child)) {
				return true;
			}
		}

		return false;
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

	public function removeChildren(beginIndex:Int = 0, endIndex:Int = 2147483647):Void {
		if (__children.length == 0) {
			return;
		}

		if (beginIndex < 0 || beginIndex >= __children.length) {
			throw "Invalid beginIndex position " + beginIndex;
		}

		var lastIndex = endIndex;
		if (lastIndex >= __children.length) {
			lastIndex = __children.length - 1;
		}

		for (i in 0...(lastIndex - beginIndex + 1)) {
			removeChildAt(beginIndex);
		}
	}

	override public function __update(deltaTime:Float):Void {
		for (child in __children) {
			child.__update(deltaTime);
		}
	}

	override public function __render(g2:Graphics, offsetX:Float, offsetY:Float):Void {
		if (!__beginRender(g2, offsetX, offsetY)) {
			return;
		}

		for (child in __children) {
			child.__render(g2, 0, 0);
		}

		__endRender(g2);
	}

	override public function __broadcastEnterFrame():Void {
		super.__broadcastEnterFrame();
		for (child in __children) {
			child.__broadcastEnterFrame();
		}
	}

	function __broadcastAddedToStageToChildren():Void {
		for (child in __children) {
			child.__broadcastAddedToStage();
			__broadcastChildAddedToStage(child);
		}
	}

	function __broadcastRemovedFromStageToChildren():Void {
		for (child in __children) {
			child.__broadcastRemovedFromStage();
			__broadcastChildRemovedFromStage(child);
		}
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

	function __childContainsParent(child:DisplayObject, parent:DisplayObject):Bool {
		var method = Reflect.field(child, "contains");
		if (method != null) {
			return Reflect.callMethod(child, method, [parent]);
		}
		return false;
	}

	override public function __getNaturalWidth():Float {
		var maxWidth = 0.0;
		for (child in __children) {
			maxWidth = Math.max(maxWidth, child.x + child.width);
		}
		return maxWidth;
	}

	override public function __getNaturalHeight():Float {
		var maxHeight = 0.0;
		for (child in __children) {
			maxHeight = Math.max(maxHeight, child.y + child.height);
		}
		return maxHeight;
	}
}
