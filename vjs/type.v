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

fn (ctx &Context) c_val(ref C.JSValue) Value {
	return Value{ref, ctx}
}

fn (ctx &Context) c_val_free(ref C.JSValue) Value {
	val := ctx.c_val(ref)
	val.free()
	return val
}

fn (ctx &Context) c_tag(tag int) Value {
	return ctx.c_val(C.JSValue{
		tag: tag
		u: &C.JSValueUnion{}
	})
}

// create js exception
pub fn (ctx &Context) js_exception() &JSError {
	return ctx.c_val(C.JS_GetException(ctx.ref)).error()
}

// create js null
pub fn (ctx &Context) js_null() Value {
	return ctx.c_tag(js_tag_null)
}

// create js undefined
pub fn (ctx &Context) js_undefined() Value {
	return ctx.c_tag(js_tag_undefined)
}

pub fn (ctx &Context) js_error(err JSError) Value {
	mut val := ctx.c_val(C.JS_NewError(ctx.ref))
	val.set('message', ctx.js_string(err.message))
	return val
}

pub fn (ctx &Context) js_uninitialized() Value {
	return ctx.c_tag(js_tag_uninitialized)
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

fn (ctx &Context) any_to_val(val AnyValue) Value {
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

// pub fn (ctx &Context) js_array() &Array {
// 	return &Array{ctx:ctx,value:ctx.c_val(C.JS_NewArray(ctx.ref))}
// }
