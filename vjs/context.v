module vjs

@[typedef]
struct C.JSContext {}

pub struct Context {
	ref &C.JSContext
	rt  Runtime
}

type EvalArgs = int | string

pub const js_tag_null = 2
pub const js_tag_undefined = 3
pub const type_global = C.JS_EVAL_TYPE_GLOBAL
pub const type_module = C.JS_EVAL_TYPE_MODULE
pub const type_compile_only = C.JS_EVAL_FLAG_COMPILE_ONLY

fn C.JS_NewContext(&C.JSRuntime) &C.JSContext
fn C.JS_FreeContext(&C.JSContext)
fn C.JS_GetException(&C.JSContext) C.JSValue
fn C.JS_Eval(&C.JSContext, &char, usize, &i8, int) C.JSValue
fn C.JS_AddIntrinsicBigFloat(&C.JSContext)
fn C.JS_AddIntrinsicBigDecimal(&C.JSContext)
fn C.JS_AddIntrinsicOperators(&C.JSContext)
fn C.JS_EnableBignumExt(&C.JSContext, int)

pub fn (rt &Runtime) new_context() Context {
	ref := C.JS_NewContext(rt.ref)
	C.JS_AddIntrinsicBigFloat(ref)
	C.JS_AddIntrinsicBigDecimal(ref)
	C.JS_AddIntrinsicOperators(ref)
	C.JS_EnableBignumExt(ref, 1)
	return Context{ref, rt}
}

pub fn (ctx &Context) eval(args ...EvalArgs) !Value {
	input := args[0] as string
	fname := if args.len == 2 { args[1] as string } else { 'code' }
	c_input := input.str
	c_fname := fname.str
	c_type := if args.len == 3 { args[2] as int } else { vjs.type_global }
	js_eval := C.JS_Eval(ctx.ref, c_input, input.len, c_fname, c_type)
	val := Value{js_eval, ctx}
	unsafe {
		free(c_fname)
		free(c_input)
	}
	return if val.is_exception() { ctx.js_exception() } else { val }
}

pub fn (ctx &Context) js_exception() &JSError {
	mut val := Value{C.JS_GetException(ctx.ref), ctx}
	return val.to_error()
}

pub fn (ctx &Context) js_null() Value {
	ref := C.JSValue{
		tag: vjs.js_tag_null
		u: &C.JSValueUnion{}
	}
	return Value{ref, ctx}
}

pub fn (ctx &Context) js_undefined() Value {
	ref := C.JSValue{
		tag: vjs.js_tag_undefined
		u: &C.JSValueUnion{}
	}
	return Value{cval, ctx}
}

@[manualfree]
pub fn (ctx &Context) free() {
	C.JS_FreeContext(ctx.ref)
}
