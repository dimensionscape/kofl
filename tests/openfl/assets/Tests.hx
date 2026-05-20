import utest.Runner;
import utest.ui.Report;

class Tests
{
	public static function main()
	{
		var runner = new Runner();
		runner.addCase(new AssetsTest());
		openfl._internal.kha.tests.UtestBridge.boot(runner, "assets");
	}
}
