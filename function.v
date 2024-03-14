module vjs

import rand

pub type JSCFunction = fn (&C.JSContext, JSValueConst, int, &JSValueConst) C.JSValue

pub type JSFunctionThis = fn (this Value, args []Value) Value

pub type JSFunction = fn (args []Value) Value

pub type JSConstructor = fn (this Value, args []Value)

@[typedef]
struct C.JSClassDef {
	class_name &char
}

@[typedef]
struct C.JSClassID {}

const ctor_code = C.JS_CFUNC_constructor

@[params]
pub struct ClassParams {
	id   ?u32
	name string
	ctor ?JSConstructor
}

fn C.JS_NewCFunction(&C.JSContext, &JSCFunction, &i8, int) C.JSValue
fn C.JS_NewCFunction2(&C.JSContext, &JSCFunction, &i8, int, int, int) C.JSValue
fn C.JS_NewClassID(&u32) C.JSClassID
fn C.JS_NewClass(&C.JSRuntime, C.JSClassID, &C.JSClassDef) int
fn C.JS_SetConstructor(&C.JSContext, JSValueConst, JSValueConst)
fn C.JS_SetClassProto(&C.JSContext, C.JSClassID, C.JSValue)
fn C.JS_NewObjectProtoClass(&C.JSContext, JSValueConst, C.JSClassID) C.JSValue

fn (ctx &Context) js_fn[T](cb T) JSCFunction {
	return fn [ctx, cb] [T](jctx &C.JSContext, this JSValueConst, len int, argv &JSValueConst) C.JSValue {
		mut args := []Value{cap: len}
		for i in 0 .. len {
			args << ctx.c_val(unsafe { argv[i] })
		}
		$if T is JSFunctionThis {
			return cb(ctx.c_val(this), args).ref
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

pub fn (ctx &Context) js_class(cls ClassParams) Value {
	ctor := cls.ctor or {
		fn (this Value, args []Value) {}
	}

	id := cls.id or { rand.u32n(1000) or { panic(err) } }
	ref := C.JS_NewClassID(&id)
	name_ptr := cls.name.str
	def := C.JSClassDef{
		class_name: name_ptr
	}
	proto := ctx.js_object()
	C.JS_NewClass(ctx.rt.ref, ref, &def)
	c_ctor := fn [ctx, ctor, ref] (jctx &C.JSContext, new_target JSValueConst, len int, argv &JSValueConst) C.JSValue {
		mut args := []Value{cap: len}
		for i in 0 .. len {
			args << ctx.c_val(unsafe { argv[i] })
		}
		target := ctx.c_val(new_target)
		proto := target.get('prototype')
		this := ctx.c_val(C.JS_NewObjectProtoClass(ctx.ref, proto.ref, ref))
		ctor(this, args)
		proto.free()
		return this.ref
	}
	class := C.JS_NewCFunction2(ctx.ref, c_ctor, name_ptr, 0, vjs.ctor_code, 0)
	C.JS_SetConstructor(ctx.ref, class, proto.ref)
	C.JS_SetClassProto(ctx.ref, ref, proto.ref)
	proto.free()
	unsafe {
		free(name_ptr)
	}
	return ctx.c_val(class)
}
