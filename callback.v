module vjs

type JSCFunction = fn (&C.JSContext, JSValueConst, int, &JSValueConst) C.JSValue

type JSFunctionThis = fn (ctx &Context, this Value, len int, args []Value) Value

type JSFunction = fn (args []Value) Value

fn C.JS_NewCFunction(&C.JSContext, &JSCFunction, &i8, int) C.JSValue

fn (ctx &Context) js_fn[T](cb T) JSCFunction {
	return fn [ctx, cb] [T](jctx &C.JSContext, this JSValueConst, len int, argv &JSValueConst) C.JSValue {
		mut args := []Value{cap: len}
		for i in 0 .. len {
			args << ctx.c_val(unsafe { argv[i] })
		}
		$if T is JSFunctionThis {
			return cb(ctx, ctx.c_val(this), len, args).ref
		} $else {
			return cb(args).ref
		}
	}
}

pub fn (ctx &Context) js_function_this(cb JSFunctionThis) Value {
	return ctx.c_val(C.JS_NewCFunction(ctx.ref, ctx.js_fn[JSFunctionThis](cb), 0, 1))
}

pub fn (ctx &Context) js_function(cb JSFunction) Value {
	return ctx.c_val(C.JS_NewCFunction(ctx.ref, ctx.js_fn[JSFunction](cb), 0, 1))
}

pub fn (ctx &Context) js_only_function_this(cb JSFunctionThis) JSCFunction {
	return ctx.js_fn[JSFunctionThis](cb)
}

pub fn (ctx &Context) js_only_function(cb JSFunction) JSCFunction {
	return ctx.js_fn[JSFunction](cb)
}
