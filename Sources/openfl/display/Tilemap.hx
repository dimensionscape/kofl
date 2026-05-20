package openfl.display;

class Tilemap extends DisplayObject implements ITileContainer {
	public var numTiles(get, never):Int;
	public var smoothing:Bool;
	public var tileAlphaEnabled:Bool;
	public var tileBlendModeEnabled:Bool;
	public var tileColorTransformEnabled:Bool;
	public var tileset(get, set):Tileset;

	var __tiles:Array<Tile> = [];
	var __tileset:Tileset;
	var __widthValue:Int;
	var __heightValue:Int;

	public function new(width:Int, height:Int, tileset:Tileset = null, smoothing:Bool = true) {
		super();
		__widthValue = width;
		__heightValue = height;
		__tileset = tileset;
		this.smoothing = smoothing;
		tileAlphaEnabled = true;
		tileBlendModeEnabled = true;
		tileColorTransformEnabled = true;
	}

	public function addTile(tile:Tile):Tile {
		if (tile != null) {
			__tiles.push(tile);
		}
		return tile;
	}

	public function addTileAt(tile:Tile, index:Int):Tile {
		if (tile != null) {
			var insertIndex = Std.int(Math.max(0, Math.min(index, __tiles.length)));
			__tiles.insert(insertIndex, tile);
		}
		return tile;
	}

	public function addTiles(tiles:Array<Tile>):Array<Tile> {
		if (tiles != null) {
			for (tile in tiles) {
				addTile(tile);
			}
		}
		return tiles;
	}

	public function contains(tile:Tile):Bool {
		return __tiles.indexOf(tile) != -1;
	}

	public function getTileAt(index:Int):Tile {
		return (index >= 0 && index < __tiles.length) ? __tiles[index] : null;
	}

	public function getTileIndex(tile:Tile):Int {
		return __tiles.indexOf(tile);
	}

	public function getTiles():TileContainer {
		var container = new TileContainer();
		for (tile in __tiles) {
			container.addTile(tile);
		}
		return container;
	}

	public function removeTile(tile:Tile):Tile {
		var index = __tiles.indexOf(tile);
		if (index >= 0) {
			__tiles.splice(index, 1);
		}
		return tile;
	}

	public function removeTileAt(index:Int):Tile {
		if (index < 0 || index >= __tiles.length) {
			return null;
		}
		var removed = __tiles[index];
		__tiles.splice(index, 1);
		return removed;
	}

	public function removeTiles(beginIndex:Int = 0, endIndex:Int = 0x7fffffff):Void {
		if (__tiles.length == 0) {
			return;
		}
		var start = Std.int(Math.max(0, beginIndex));
		var finish = Std.int(Math.min(__tiles.length - 1, endIndex));
		if (finish < start) {
			return;
		}
		__tiles.splice(start, finish - start + 1);
	}

	public function setTileIndex(tile:Tile, index:Int):Void {
		var currentIndex = __tiles.indexOf(tile);
		if (currentIndex == -1) {
			return;
		}

		__tiles.splice(currentIndex, 1);
		__tiles.insert(Std.int(Math.max(0, Math.min(index, __tiles.length))), tile);
	}

	public function setTiles(group:TileContainer):Void {
		__tiles = [];
		if (group != null) {
			for (i in 0...group.numTiles) {
				__tiles.push(group.getTileAt(i));
			}
		}
	}

	public function sortTiles(compareFunction:Tile->Tile->Int):Void {
		if (compareFunction != null) {
			__tiles.sort(compareFunction);
		}
	}

	public function swapTiles(tile1:Tile, tile2:Tile):Void {
		var index1 = __tiles.indexOf(tile1);
		var index2 = __tiles.indexOf(tile2);
		if (index1 == -1 || index2 == -1) {
			return;
		}
		swapTilesAt(index1, index2);
	}

	public function swapTilesAt(index1:Int, index2:Int):Void {
		if (index1 < 0 || index1 >= __tiles.length || index2 < 0 || index2 >= __tiles.length) {
			return;
		}

		var temp = __tiles[index1];
		__tiles[index1] = __tiles[index2];
		__tiles[index2] = temp;
	}

	override public function __getNaturalWidth():Float {
		return __widthValue;
	}

	override public function __getNaturalHeight():Float {
		return __heightValue;
	}

	override function get_width():Float {
		return __widthValue * scaleX;
	}

	override function set_width(value:Float):Float {
		__widthValue = Std.int(value);
		return value;
	}

	override function get_height():Float {
		return __heightValue * scaleY;
	}

	override function set_height(value:Float):Float {
		__heightValue = Std.int(value);
		return value;
	}

	function get_numTiles():Int {
		return __tiles.length;
	}

	function get_tileset():Tileset {
		return __tileset;
	}

	function set_tileset(value:Tileset):Tileset {
		__tileset = value;
		return value;
	}
}
