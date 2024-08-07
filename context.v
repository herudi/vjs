module vjs

@[typedef]
struct C.JSContext {}

@[typedef]
struct C.JSModuleDef {}

// Context structure based on `JSContext` in qjs
// and implemented into `ref`.
pub struct Context {
	ref &C.JSContext
	rt  Runtime
}

type SetMeta = fn (Context, JSValueConst)

// ContextConfig structure params.
@[params]
pub struct ContextConfig {
	unhandled_rejection bool = true
	bignum              bool = true
	module_std          bool
}

// EvalCoreConfig structure params.
@[params]
pub struct EvalCoreConfig {
	input    &char
	len      usize
	fname    &char
	flag     int
	set_meta SetMeta @[required]
}

type EvalArgs = int | string

type FnNewContext = fn (&C.JSRuntime) &C.JSContext

type JSModuleNormalizeFunc = fn (&C.JSContext, &char, &char, voidptr) &char

type JSModuleLoaderFunc = fn (&C.JSContext, &char, voidptr) &C.JSModuleDef

// Evaluate JS type global.
pub const type_global = C.JS_EVAL_TYPE_GLOBAL

// Evaluate JS type module.
pub const type_module = C.JS_EVAL_TYPE_MODULE

// Evaluate JS type direct.
pub const type_direct = C.JS_EVAL_TYPE_DIRECT

// Evaluate JS type indirect.
pub const type_indirect = C.JS_EVAL_TYPE_INDIRECT

// Evaluate JS type mask.
pub const type_mask = C.JS_EVAL_TYPE_MASK

// Evaluate JS type strict.
pub const type_strict = C.JS_EVAL_FLAG_STRICT

// Evaluate JS type strip.
pub const type_strip = C.JS_EVAL_FLAG_STRIP

// Evaluate JS type compile only.
pub const type_compile_only = C.JS_EVAL_FLAG_COMPILE_ONLY

// Evaluate JS type barrier.
pub const type_barrier = C.JS_EVAL_FLAG_BACKTRACE_BARRIER

// Evaluate JS type async.
pub const type_async = C.JS_EVAL_FLAG_ASYNC

fn C.js_std_init_handlers(&C.JSRuntime)
fn C.js_init_module_std(&C.JSContext, &char) &C.JSModuleDef
fn C.js_init_module_os(&C.JSContext, &char) &C.JSModuleDef
fn C.JS_NewContext(&C.JSRuntime) &C.JSContext
fn C.JS_FreeContext(&C.JSContext)
fn C.js_std_dump_error(&C.JSContext)
fn C.js_free(&C.JSContext, voidptr)
fn C.JS_Eval(&C.JSContext, &char, usize, &char, int) C.JSValue
fn C.JS_AddIntrinsicBigFloat(&C.JSContext)
fn C.JS_AddIntrinsicBigDecimal(&C.JSContext)
fn C.JS_AddIntrinsicOperators(&C.JSContext)
fn C.JS_EnableBignumExt(&C.JSContext, int)
fn C.JS_DupContext(&C.JSContext) &C.JSContext
fn C.JS_EvalFunction(&C.JSContext, C.JSValue) C.JSValue
fn C.js_std_await(&C.JSContext, C.JSValue) C.JSValue
fn C.js_std_set_worker_new_context_func(FnNewContext)
fn C.JS_SetModuleLoaderFunc(&C.JSRuntime, &JSModuleNormalizeFunc, &JSModuleLoaderFunc, voidptr)
fn C.js_module_loader(&C.JSContext, &char, voidptr) &C.JSModuleDef
fn C.js_std_loop(&C.JSContext)
fn C.JS_GetRuntime(&C.JSContext) &C.JSRuntime
fn C.js_std_free_handlers(&C.JSRuntime)
fn C.js_std_add_helpers(&C.JSContext, int, &&char)
fn C.js_load_file(&C.JSContext, &usize, &char) &u8
fn C.js_module_set_import_meta(&C.JSContext, JSValueConst, bool, bool) int
fn C.JS_CallConstructor(&C.JSContext, JSValueConst, int, &JSValueConst) C.JSValue

fn def_set_meta(ctx Context, ref JSValueConst) {
	C.js_module_set_import_meta(ctx.ref, ref, true, true)
}

fn fn_custom_context(config ContextConfig) FnNewContext {
	return fn [config] (rt &C.JSRuntime) &C.JSContext {
		ref := C.JS_NewContext(rt)
		if config.bignum {
			C.JS_AddIntrinsicBigFloat(ref)
			C.JS_AddIntrinsicBigDecimal(ref)
			C.JS_AddIntrinsicOperators(ref)
			C.JS_EnableBignumExt(ref, 1)
		}
		if config.module_std {
			C.js_init_module_std(ref, c'std')
		}
		C.js_init_module_os(ref, c'os')
		return ref
	}
}

// Create new Context from `Runtime`.
// Example:
// ```v
// rt := vjs.new_runtime()
// ctx := rt.new_context(opts_config)
// ```
pub fn (rt Runtime) new_context(config ContextConfig) &Context {
	new_context := fn_custom_context(config)
	C.js_std_set_worker_new_context_func(new_context)
	C.js_std_init_handlers(rt.ref)
	ref := new_context(rt.ref)
	C.JS_SetModuleLoaderFunc(rt.ref, C.NULL, &C.js_module_loader, C.NULL)
	if config.unhandled_rejection {
		rt.promise_rejection_tracker()
	}
	ctx := &Context{
		ref: ref
		rt: rt
	}
	return ctx
}

// Core evaluate JS
@[manualfree]
pub fn (ctx &Context) js_eval_core(op EvalCoreConfig) !Value {
	mut ref := ctx.js_undefined().ref
	input := op.input
	len := op.len
	fname := op.fname
	flag := op.flag
	set_meta := op.set_meta
	if (flag & vjs.type_mask) == vjs.type_module {
		ref = C.JS_Eval(ctx.ref, input, len, fname, flag | vjs.type_compile_only)
		if C.JS_IsException(ref) == 0 {
			set_meta(ctx, ref)
			ref = C.JS_EvalFunction(ctx.ref, ref)
		}
		ref = C.js_std_await(ctx.ref, ref)
	} else {
		ref = C.JS_Eval(ctx.ref, input, len, fname, flag)
	}
	val := ctx.c_val(ref)
	unsafe {
		free(fname)
		free(input)
	}
	if val.is_exception() {
		return ctx.js_exception()
	}
	return val
}

// Evaluate JS with complete params
// Example: ctx.js_eval(code, filename, flag)!
pub fn (ctx &Context) js_eval(input string, fname string, flag int) !Value {
	return ctx.js_eval_core(
		input: input.str
		len: usize(input.len)
		fname: fname.str
		flag: flag
		set_meta: fn (ctx Context, ref JSValueConst) {}
	)!
}

// Evaluate JS
// Example:
// ```v
// val1 := ctx.eval('1 + 1')!
//
// // or module
// val2 := ctx.eval('1 + 1', vjs.type_module)!
// ```
pub fn (ctx &Context) eval(args ...EvalArgs) !Value {
	input := args[0] as string
	flag := if args.len == 2 { args[1] as int } else { vjs.type_global }
	return ctx.js_eval(input, '<input>', flag)
}

// Evaluate JS module
// Example:
// ```v
// ctx.eval_module('1 + 1', 'index.js')!
// ```
pub fn (ctx &Context) eval_module(input string, fname string) !Value {
	return ctx.js_eval(input, fname, vjs.type_module)
}

// Evaluate File with metadata
// Example:
// ```v
// ctx.eval_file_custom_meta('./path/to/file.js', vjs.type_module, set_meta_fn)!
// ```
@[manualfree]
pub fn (ctx &Context) eval_file_custom_meta(fname string, flag int, set_meta SetMeta) !Value {
	c_fname := fname.str
	mut buf_len := usize(0)
	buf := C.js_load_file(ctx.ref, &buf_len, c_fname)
	if isnil(buf) {
		return error('${fname} file not found')
	}
	val := ctx.js_eval_core(
		input: buf
		len: buf_len
		fname: c_fname
		flag: flag
		set_meta: set_meta
	)!
	C.js_free(ctx.ref, buf)
	return val
}

// Evaluate File
// Example:
// ```v
// ctx.eval_file('./path/to/file.js')!
//
// // or module
// ctx.eval_file('./path/to/file.js', vjs.type_module)!
// ```
@[manualfree]
pub fn (ctx &Context) eval_file(args ...EvalArgs) !Value {
	fname := args[0] as string
	flag := if args.len == 2 { args[1] as int } else { vjs.type_global }
	return ctx.eval_file_custom_meta(fname, flag, def_set_meta)
}

// Evaluate Function
pub fn (ctx &Context) eval_function(val Value) Value {
	return ctx.c_val(C.JS_EvalFunction(ctx.ref, val.ref))
}

// Callback this from Context
pub fn (ctx &Context) call_this(this Value, val Value, args ...AnyValue) !Value {
	c_args := args.map(ctx.any_to_val(it).ref)
	c_val := if c_args.len == 0 { unsafe { nil } } else { &c_args[0] }
	ret := ctx.c_val(C.JS_Call(ctx.ref, val.ref, this.ref, c_args.len, c_val))
	if ret.is_exception() {
		return ctx.js_exception()
	}
	return ret
}

// Callback from Context
pub fn (ctx &Context) call(val Value, args ...AnyValue) !Value {
	return ctx.call_this(ctx.js_null(), val, ...args)
}

// Duplicate context
pub fn (ctx &Context) dup_context() &Context {
	ref := C.JS_DupContext(ctx.ref)
	return &Context{
		ref: ref
		rt: ctx.rt
	}
}

// Dump std Error
pub fn (ctx &Context) dump_error() Value {
	C.js_std_dump_error(ctx.ref)
	return ctx.js_undefined()
}

// std loop form `qjs`
pub fn (ctx &Context) loop() {
	C.js_std_loop(ctx.ref)
}

// Context end
pub fn (ctx &Context) end() {
	ctx.loop()
}

// Get runtime from context
pub fn (ctx &Context) runtime() Runtime {
	return Runtime{
		ref: C.JS_GetRuntime(ctx.ref)
	}
}

// Free the context
pub fn (ctx &Context) free() {
	C.js_std_free_handlers(ctx.rt.ref)
	C.JS_FreeContext(ctx.ref)
}
