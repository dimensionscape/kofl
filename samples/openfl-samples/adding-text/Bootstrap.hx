package;

import openfl._internal.kha.samples.SampleRunner;

class Bootstrap {
	public static function main():Void {
		SampleRunner.run("Adding Text", 800, 600, 0xFFFFFF, function() return new Main());
	}
}
