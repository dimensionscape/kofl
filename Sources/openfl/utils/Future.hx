package openfl.utils;

#if !lime
@SuppressWarnings("checkstyle:FieldDocComment")
class Future<T>
{
	public var error:Dynamic;
	public var isComplete:Bool;
	public var isError:Bool;
	public var value:T;

	@:allow(openfl.utils.Promise) var __completeListeners:Array<T->Void>;
	@:allow(openfl.utils.Promise) var __errorListeners:Array<Dynamic->Void>;
	@:allow(openfl.utils.Promise) var __progressListeners:Array<Int->Int->Void>;

	public function new() {}

	public function onComplete(listener:T->Void):Future<T>
	{
		if (listener == null)
		{
			return this;
		}

		if (isComplete && !isError)
		{
			listener(value);
		}
		else
		{
			if (__completeListeners == null) __completeListeners = [];
			__completeListeners.push(listener);
		}

		return this;
	}

	public function onError(listener:Dynamic->Void):Future<T>
	{
		if (listener == null)
		{
			return this;
		}

		if (isError)
		{
			listener(error);
		}
		else
		{
			if (__errorListeners == null) __errorListeners = [];
			__errorListeners.push(listener);
		}

		return this;
	}

	public function onProgress(listener:Int->Int->Void):Future<T>
	{
		if (listener != null)
		{
			if (__progressListeners == null) __progressListeners = [];
			__progressListeners.push(listener);
		}

		return this;
	}

	public function ready(waitTime:Int = -1):Future<T>
	{
		return this;
	}

	public function result(waitTime:Int = -1):Null<T>
	{
		return value;
	}

	public function then<U>(next:T->Future<U>):Future<U>
	{
		if (next == null)
		{
			var failed = new Future<U>();
			failed.error = "Missing continuation";
			failed.isError = true;
			return failed;
		}

		var promise = new Promise<U>();

		onComplete(function(currentValue:T)
		{
			var nextFuture = next(currentValue);
			if (nextFuture == null)
			{
				promise.complete(cast null);
			}
			else
			{
				promise.completeWith(nextFuture);
			}
		});

		onError(function(currentError:Dynamic)
		{
			promise.error(currentError);
		});

		return promise.future;
	}

	public static function withError(error:Dynamic):Future<Dynamic>
	{
		var result = new Future<Dynamic>();
		result.error = error;
		result.isError = true;
		return result;
	}

	public static function withValue<T>(value:T):Future<T>
	{
		var result = new Future<T>();
		result.value = value;
		result.isComplete = true;
		return result;
	}
}
#else
typedef Future<T> = lime.app.Future<T>;
#end
