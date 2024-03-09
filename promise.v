module vjs

type JSHostPromiseRejectionTracker = fn (&C.JSContext, JSValueConst, JSValueConst, bool, voidptr)

fn C.JS_NewPromiseCapability(&C.JSContext, &C.JSValue) C.JSValue
fn C.JS_SetHostPromiseRejectionTracker(&C.JSRuntime, &JSHostPromiseRejectionTracker, voidptr)
fn C.js_std_promise_rejection_tracker(&C.JSContext, JSValueConst, JSValueConst, bool, voidptr)

pub struct Promise {
	ctx Context
}

@[manualfree]
fn resolve_or_reject(ctx &Context, code int, any AnyValue) Value {
	resolving_funcs := [2]C.JSValue{}
	mut result_funcs := [2]C.JSValue{}
	result_funcs[code] = ctx.any_to_val(any).ref
	promise := ctx.c_val(C.JS_NewPromiseCapability(ctx.ref, &resolving_funcs[0]))
	C.JS_Call(ctx.ref, resolving_funcs[code], promise.ref, 1, &result_funcs[code])
	C.JS_FreeValue(ctx.ref, resolving_funcs[0])
	C.JS_FreeValue(ctx.ref, resolving_funcs[1])
	C.JS_FreeValue(ctx.ref, result_funcs[code])
	return promise
}

pub fn (ctx &Context) js_promise() Promise {
	return Promise{
		ctx: ctx
	}
}

pub fn (p Promise) resolve(any AnyValue) Value {
	return resolve_or_reject(p.ctx, 0, any)
}

pub fn (p Promise) reject(any AnyValue) Value {
	return resolve_or_reject(p.ctx, 1, any)
}

pub fn (rt Runtime) promise_rejection_tracker() {
	C.JS_SetHostPromiseRejectionTracker(rt.ref, &C.js_std_promise_rejection_tracker, C.NULL)
}
