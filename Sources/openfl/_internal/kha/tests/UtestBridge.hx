package openfl._internal.kha.tests;

import haxe.Json;
import haxe.Timer;
#if kha
import kha.Assets;
import kha.System;
#end
import utest.Assertation;
import utest.Runner;
import utest.TestResult;
import utest.ui.Report;

#if js
import js.Browser;
#end

class UtestBridge
{
	static var __runtimeStarted = false;

	public static function boot(runner:Runner, suiteName:String):Void
	{
		attach(runner, suiteName);

		var outputPath:String = null;
		#if sys
		outputPath = Sys.getEnv("KOFL_UTEST_RESULT_PATH");
		if (outputPath == null || outputPath == "") {
			outputPath = "kofl-utest-result.json";
		}
		#end

		var startRunner = function() {
		try {
			savePayload({
				suite: suiteName,
				status: "booting",
				phase: "beforeResolvedProbe",
				total: runner.length
			}
			#if sys
			, outputPath
			#end
			);
			@:privateAccess utest.Async.getResolved();
			savePayload({
				suite: suiteName,
				status: "booting",
				phase: "afterResolvedProbe",
				total: runner.length
			}
			#if sys
			, outputPath
			#end
			);
			savePayload({
				suite: suiteName,
				status: "booting",
				phase: "beforeReportCreate",
				total: runner.length
			}
			#if sys
			, outputPath
			#end
			);
			Report.create(runner);
			savePayload({
				suite: suiteName,
				status: "booting",
				phase: "afterReportCreate",
				total: runner.length
			}
			#if sys
			, outputPath
			#end
			);
			savePayload({
				suite: suiteName,
				status: "booting",
				phase: "beforeRunnerRun",
				total: runner.length
			}
			#if sys
			, outputPath
			#end
			);
			runner.run();
			savePayload({
				suite: suiteName,
				status: "booting",
				phase: "afterRunnerRun",
				total: runner.length
			}
			#if sys
			, outputPath
			#end
			);
		} catch (error:Dynamic) {
			var payload = {
				suite: suiteName,
				status: "crashed",
				phase: "exception",
				completed: 0,
				total: runner.length,
				passed: false,
				failed: 1,
				failures: [
					{
						kind: "exception",
						caseName: suiteName,
						method: "runner.run",
						message: Std.string(error)
					}
				]
			};

			#if sys
			savePayload(payload, outputPath);
			Timer.delay(function() Sys.exit(1), 10);
			#elseif js
			untyped Browser.window.__koflUtestResult = payload;
			#end
		}
		};

		#if kha
		if (!__runtimeStarted) {
			__runtimeStarted = true;
			savePayload({
				suite: suiteName,
				status: "booting",
				phase: "beforeKhaStart",
				total: runner.length
			}
			#if sys
			, outputPath
			#end
			);

			System.start({
				title: "KOFL OpenFL Tests - " + suiteName,
				width: 64,
				height: 64
			}, function(_) {
				savePayload({
					suite: suiteName,
					status: "booting",
					phase: "beforeAssetLoad",
					total: runner.length
				}
				#if sys
				, outputPath
				#end
				);

				Assets.loadEverything(function() {
					savePayload({
						suite: suiteName,
						status: "booting",
						phase: "afterAssetLoad",
						total: runner.length
					}
					#if sys
					, outputPath
					#end
					);
					startRunner();
				}, null, null, function(error) {
					savePayload({
						suite: suiteName,
						status: "crashed",
						phase: "assetLoadFailure",
						completed: 0,
						total: runner.length,
						passed: false,
						failed: 1,
						failures: [
							{
								kind: "assetLoadFailure",
								caseName: suiteName,
								method: "Assets.loadEverything",
								message: Std.string(error)
							}
						]
					}
					#if sys
					, outputPath
					#end
					);
				});
			});
			return;
		}
		#end

		startRunner();
	}

	public static function attach(runner:Runner, suiteName:String):Void
	{
		var failures:Array<Dynamic> = [];
		var warnings:Array<Dynamic> = [];
		var ignored:Array<Dynamic> = [];
		var completed = 0;
		var total = 0;
		var currentCase:String = null;
		var currentMethod:String = null;
		var lastCompletedCase:String = null;
		var lastCompletedMethod:String = null;
		#if sys
		var outputPath = Sys.getEnv("KOFL_UTEST_RESULT_PATH");
		if (outputPath == null || outputPath == "") {
			outputPath = "kofl-utest-result.json";
		}
		#end

		runner.onStart.add(function(_)
		{
			total = runner.length;
			savePayload({
				suite: suiteName,
				status: "running",
				completed: completed,
				total: total,
				currentCase: currentCase,
				currentMethod: currentMethod,
				lastCompletedCase: lastCompletedCase,
				lastCompletedMethod: lastCompletedMethod,
				failed: failures.length,
				warnings: warnings.length,
				ignored: ignored.length
			}
			#if sys
			, outputPath
			#end
			);
		});

		runner.onProgress.add(function(progress)
		{
			completed = progress.done;
			total = progress.totals;
			record(progress.result, failures, warnings, ignored);
			savePayload({
				suite: suiteName,
				status: "running",
				completed: completed,
				total: total,
				currentCase: currentCase,
				currentMethod: currentMethod,
				lastCompletedCase: lastCompletedCase,
				lastCompletedMethod: lastCompletedMethod,
				failed: failures.length,
				warnings: warnings.length,
				ignored: ignored.length,
				failures: failures
			}
			#if sys
			, outputPath
			#end
			);
		});

		runner.onComplete.add(function(_)
		{
			var payload:Dynamic = {
				suite: suiteName,
				status: "complete",
				completed: completed,
				total: total,
				currentCase: currentCase,
				currentMethod: currentMethod,
				lastCompletedCase: lastCompletedCase,
				lastCompletedMethod: lastCompletedMethod,
				failed: failures.length,
				warnings: warnings.length,
				ignored: ignored.length,
				passed: failures.length == 0,
				failures: failures,
				warningsList: warnings,
				ignoredList: ignored
			};

			#if sys
			savePayload(payload, outputPath);
			Timer.delay(function() Sys.exit(failures.length == 0 ? 0 : 1), 10);
			#elseif js
			untyped Browser.window.__koflUtestResult = payload;
			if (Browser.document != null && Browser.document.body != null) {
				Browser.document.body.setAttribute("data-kofl-utest-status", failures.length == 0 ? "passed" : "failed");
				Browser.document.body.setAttribute("data-kofl-utest-suite", suiteName);
				Browser.document.body.setAttribute("data-kofl-utest-failures", Std.string(failures.length));
			}
			#end
		});

		runner.onTestStart.add(function(handler)
		{
			currentCase = Type.getClassName(Type.getClass(handler.fixture.target));
			currentMethod = handler.fixture.method;
			savePayload({
				suite: suiteName,
				status: "running",
				completed: completed,
				total: total,
				currentCase: currentCase,
				currentMethod: currentMethod,
				lastCompletedCase: lastCompletedCase,
				lastCompletedMethod: lastCompletedMethod,
				failed: failures.length,
				warnings: warnings.length,
				ignored: ignored.length
			}
			#if sys
			, outputPath
			#end
			);
		});

		runner.onTestComplete.add(function(handler)
		{
			lastCompletedCase = Type.getClassName(Type.getClass(handler.fixture.target));
			lastCompletedMethod = handler.fixture.method;
		});
	}

	static function record(result:TestResult, failures:Array<Dynamic>, warnings:Array<Dynamic>, ignored:Array<Dynamic>):Void
	{
		for (assertation in result.assertations) {
			switch (assertation) {
				case Success(_):
				case Warning(msg):
					warnings.push(describe(result, "warning", msg));
				case Ignore(reason):
					ignored.push(describe(result, "ignored", reason));
				case Failure(msg, pos):
					failures.push(describe(result, "failure", msg, pos));
				case Error(error, stack):
					failures.push(describe(result, "error", Std.string(error), null, stack));
				case SetupError(error, stack):
					failures.push(describe(result, "setupError", Std.string(error), null, stack));
				case TeardownError(error, stack):
					failures.push(describe(result, "teardownError", Std.string(error), null, stack));
				case TimeoutError(missedAsyncs, stack):
					failures.push(describe(result, "timeout", 'Missed async count: $missedAsyncs', null, stack));
				case AsyncError(error, stack):
					failures.push(describe(result, "asyncError", Std.string(error), null, stack));
			}
		}
	}

	static function describe(result:TestResult, kind:String, message:String, ?pos:Dynamic, ?stack:Dynamic):Dynamic
	{
		return {
			kind: kind,
			caseName: result.pack == null || result.pack == "" ? result.cls : result.pack + "." + result.cls,
			method: result.method,
			message: message,
			position: pos,
			stack: stack
		};
	}

	#if sys
	static function savePayload(payload:Dynamic, outputPath:String):Void
	{
		sys.io.File.saveContent(outputPath, Json.stringify(payload, null, "\t"));
	}
	#else
	static function savePayload(payload:Dynamic):Void {}
	#end
}
