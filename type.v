module vjs

pub type AnyValue = Value | bool | f64 | i64 | int | string | u32 | u64

// Context JS TypeData.
fn C.JS_NewString(&C.JSContext, &char) C.JSValue
fn C.JS_NewBool(&C.JSContext, int) C.JSValue
fn C.JS_NewInt32(&C.JSContext, int) C.JSValue
fn C.JS_NewInt64(&C.JSContext, i64) C.JSValue
fn C.JS_NewBigUint64(&C.JSContext, u64) C.JSValue
fn C.JS_NewBigInt64(&C.JSContext, i64) C.JSValue
fn C.JS_NewUint32(&C.JSContext, u32) C.JSValue
fn C.JS_NewFloat64(&C.JSContext, f64) C.JSValue
fn C.JS_NewArray(&C.JSContext) C.JSValue
fn C.JS_NewArrayBufferCopy(&C.JSContext, u8, usize) C.JSValue
fn C.JS_GetGlobalObject(&C.JSContext) C.JSValue
fn C.JS_NewObject(&C.JSContext) C.JSValue
fn C.JS_NewError(&C.JSContext) C.JSValue
fn C.JS_GetException(&C.JSContext) C.JSValue
fn C.JS_Throw(&C.JSContext, C.JSValue) C.JSValue
fn C.JS_ParseJSON(&C.JSContext, &char, usize, &char) C.JSValue

fn (ctx &Context) c_val(ref C.JSValue) Value {
	return Value{ref, ctx}
}

fn (ctx &Context) c_tag(tag int) Value {
	return ctx.c_val(C.JSValue{
		tag: tag
		u: &C.JSValueUnion{}
	})
}

// create js exception
pub fn (ctx &Context) js_exception() &JSError {
	val := ctx.c_val(C.JS_GetException(ctx.ref))
	err := val.to_error()
	val.free()
	return err
}

// create js null
pub fn (ctx &Context) js_null() Value {
	return ctx.c_tag(2)
}

// create js undefined
pub fn (ctx &Context) js_undefined() Value {
	return ctx.c_tag(3)
}

pub fn (ctx &Context) js_uninitialized() Value {
	return ctx.c_tag(4)
}

pub fn (ctx &Context) json_stringify_op(val Value, rep Value, ind AnyValue) string {
	indent := ctx.any_to_val(ind)
	ref := C.JS_JSONStringify(ctx.ref, val.ref, rep.ref, indent.ref)
	ptr := C.JS_ToCString(ctx.ref, ref)
	C.JS_FreeCString(ctx.ref, ptr)
	u_free(ptr)
	return v_str(ptr)
}

pub fn (ctx &Context) json_stringify(val Value) string {
	null := ctx.js_null()
	return ctx.json_stringify_op(val, null, null)
}

pub fn (ctx &Context) json_parse(str string) Value {
	len := str.len
	c_str := str.str
	c_fname := ''.str
	unsafe {
		free(c_fname)
		free(c_str)
	}
	return ctx.c_val(C.JS_ParseJSON(ctx.ref, c_str, usize(len), c_fname))
}

pub fn (ctx &Context) js_throw(any AnyValue) Value {
	val := ctx.any_to_val(any)
	return ctx.c_val(C.JS_Throw(ctx.ref, val.ref))
}

pub fn (ctx &Context) js_error(err JSError) Value {
	val := ctx.c_val(C.JS_NewError(ctx.ref))
	val.set('name', ctx.js_string(err.name))
	val.set('message', ctx.js_string(err.message))
	if err.stack != '' {
		val.set('stack', ctx.js_string(err.stack))
	}
	return val
}

pub fn (ctx &Context) js_type_error(err JSError) Value {
	mut terr := err
	terr.name = 'TypeError'
	return ctx.js_error(terr)
}

pub fn (ctx &Context) js_dump(err IError) Value {
	val := ctx.c_val(C.JS_NewError(ctx.ref))
	val.set('message', ctx.js_string(err.msg()))
	return val
}

pub fn (ctx &Context) js_string(data string) Value {
	return ctx.c_val(C.JS_NewString(ctx.ref, u_free(data.str)))
}

pub fn (ctx &Context) js_bool(data bool) Value {
	return ctx.c_val(C.JS_NewBool(ctx.ref, if data { 1 } else { 0 }))
}

pub fn (ctx &Context) js_int(data int) Value {
	return ctx.c_val(C.JS_NewInt32(ctx.ref, data))
}

pub fn (ctx &Context) js_u32(data u32) Value {
	return ctx.c_val(C.JS_NewUint32(ctx.ref, data))
}

pub fn (ctx &Context) js_big_int(data i64) Value {
	return ctx.c_val(C.JS_NewBigInt64(ctx.ref, data))
}

pub fn (ctx &Context) js_big_uint(data u64) Value {
	return ctx.c_val(C.JS_NewBigUint64(ctx.ref, data))
}

pub fn (ctx &Context) js_i64(data i64) Value {
	return ctx.c_val(C.JS_NewInt64(ctx.ref, data))
}

pub fn (ctx &Context) js_float(data f64) Value {
	return ctx.c_val(C.JS_NewFloat64(ctx.ref, data))
}

pub fn (ctx &Context) js_object() Value {
	return ctx.c_val(C.JS_NewObject(ctx.ref))
}

pub fn (ctx &Context) js_global() Value {
	return ctx.c_val(C.JS_GetGlobalObject(ctx.ref))
}

pub fn (ctx &Context) any_to_val(val AnyValue) Value {
	if val is Value {
		return val
	}
	if val is string {
		return ctx.js_string(val)
	}
	if val is bool {
		return ctx.js_bool(val)
	}
	if val is int {
		return ctx.js_int(val)
	}
	if val is i64 {
		return ctx.js_big_int(val)
	}
	if val is u64 {
		return ctx.js_big_uint(val)
	}
	if val is f64 {
		return ctx.js_float(val)
	}
	return ctx.js_u32(val as u32)
}

pub fn (ctx &Context) js_array() Value {
	return ctx.c_val(C.JS_NewArray(ctx.ref))
}
