package lime.ui;

class Touch
{
	public static var onEnd:TouchSignal = new TouchSignal();
	public static var onMove:TouchSignal = new TouchSignal();
	public static var onStart:TouchSignal = new TouchSignal();

	public var device:Int;
	public var dx:Float;
	public var dy:Float;
	public var id:Int;
	public var pressure:Float;
	public var x:Float;
	public var y:Float;

	public function new(x:Float, y:Float, id:Int, dx:Float, dy:Float, pressure:Float, device:Int)
	{
		this.x = x;
		this.y = y;
		this.id = id;
		this.dx = dx;
		this.dy = dy;
		this.pressure = pressure;
		this.device = device;
	}
}

class TouchSignal
{
	public function new()
	{
	}

	public function dispatch(touch:Touch):Void
	{
	}
}
