module vjs

type JSHostPromiseRejectionTracker = fn (&C.JSContext, JSValueConst, JSValueConst, bool, voidptr)

// `type` Callback JS Promise.
pub type CallbackPromise = fn (Promise) Value

// `enum` Promise State
pub enum JSPromiseStateEnum {
	pending
	resolved
	rejected
}

fn C.JS_NewPromiseCapability(&C.JSContext, &C.JSValue) C.JSValue
fn C.JS_SetHostPromiseRejectionTracker(&C.JSRuntime, &JSHostPromiseRejectionTracker, voidptr)
fn C.js_std_promise_rejection_tracker(&C.JSContext, JSValueConst, JSValueConst, bool, voidptr)
fn C.JS_PromiseState(&C.JSContext, C.JSValue) JSPromiseStateEnum
fn C.JS_PromiseResult(&C.JSContext, C.JSValue) C.JSValue

// Promise structure.
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

// Create new Promise.
// Example:
// ```v
// promise := ctx.new_promise(fn [ctx](p Promise) Value {
// 	 if err {
// 		 return p.reject(ctx.js_error(message: 'rejected'))
// 	 }
// 	 return p.resolve(ctx.js_string('resolved'))
// })
//
// value := promise.await()
// println(value)
// ```
pub fn (ctx &Context) new_promise(cb CallbackPromise) Value {
	return cb(Promise{ctx})
}

// Same as new_promise, but without callback.
pub fn (ctx &Context) js_promise() Promise {
	return Promise{
		ctx: ctx
	}
}

// Promise resolve
pub fn (p Promise) resolve(any AnyValue) Value {
	return resolve_or_reject(p.ctx, 0, any)
}

// Promise reject
pub fn (p Promise) reject(any AnyValue) Value {
	return resolve_or_reject(p.ctx, 1, any)
}

// Promise rejection tracker (default true)
pub fn (rt Runtime) promise_rejection_tracker() {
	C.JS_SetHostPromiseRejectionTracker(rt.ref, &C.js_std_promise_rejection_tracker, C.NULL)
}

// Get Promise State
pub fn (ctx &Context) promise_state(val Value) Value {
	state := C.JS_PromiseState(ctx.ref, val.ref)
	return ctx.js_string(state.str())
}

// Get Promise Result
pub fn (ctx &Context) promise_result(val Value) Value {
	res := ctx.c_val(C.JS_PromiseResult(ctx.ref, val.ref))
	return res
}
