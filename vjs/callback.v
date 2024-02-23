module vjs

type JSCFunction = fn (&C.JSContext, JSValueConst, int, &JSValueConst) C.JSValue

type JSCallback = fn (&Context, Value, []Value) Value

fn C.JS_NewCFunction(&C.JSContext, &JSCFunction, &i8, int) C.JSValue

pub fn (ctx &Context) js_callback(cb JSCallback) Value {
	js_fn := fn [cb, ctx] (jctx &C.JSContext, this JSValueConst, len int, argv &JSValueConst) C.JSValue {
		mut args := []Value{cap: len}
		for i in 0 .. len {
			args << ctx.c_val(unsafe { argv[i] })
		}
		return cb(ctx, ctx.c_val(this), args).ref
	}
	return ctx.c_val(C.JS_NewCFunction(ctx.ref, js_fn, unsafe { nil }, 0))
}
