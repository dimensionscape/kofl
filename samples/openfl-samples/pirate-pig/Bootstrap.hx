package;

import openfl._internal.kha.samples.SampleRunner;
import piratepig.PiratePig;

class Bootstrap {
	public static function main():Void {
		SampleRunner.run("Pirate Pig", 800, 600, 0xD9F3FF, function() return new PiratePig());
	}
}
