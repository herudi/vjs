module vjs

type JSCFunction = fn (&C.JSContext, JSValueConst, int, &JSValueConst) C.JSValue

type JSCallback = fn (&Context, []Value) Value

pub fn (ctx &Context) js_callback(cb JSCallback) Value {
	js_fn := fn [cb, ctx] (jctx &C.JSContext, jval JSValueConst, len int, argv &JSValueConst) C.JSValue {
		mut args := []Value{cap: len}
		for i in 0 .. len {
			args << ctx.c_val(unsafe { argv[i] })
		}
		val := cb(ctx, args)
		return val.ref
	}
	return ctx.c_val(C.JS_NewCFunction(ctx.ref, js_fn, 0, 0))
}
