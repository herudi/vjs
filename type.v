module vjs

// `type` Anything Value in `vjs`
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
fn C.JS_NewArrayBufferCopy(&C.JSContext, &u8, usize) C.JSValue
fn C.JS_CallConstructor(&C.JSContext, JSValueConst, int, &JSValueConst) C.JSValue

fn (ctx &Context) c_val(ref C.JSValue) Value {
	return Value{ref, ctx}
}

fn (ctx &Context) c_tag(tag int) Value {
	return ctx.c_val(C.JSValue{
		tag: tag
		u: &C.JSValueUnion{}
	})
}

// Create JS Exception.
// Example:
// ```v
// if val.is_exception() {
//   return ctx.js_exception()
// }
// ```
@[manualfree]
pub fn (ctx &Context) js_exception() &JSError {
	val := ctx.c_val(C.JS_GetException(ctx.ref))
	err := val.to_error()
	val.free()
	return err
}

// Create JS Null.
pub fn (ctx &Context) js_null() Value {
	return ctx.c_tag(2)
}

// Create JS Undefined.
pub fn (ctx &Context) js_undefined() Value {
	return ctx.c_tag(3)
}

// Create JS Uninitialized.
pub fn (ctx &Context) js_uninitialized() Value {
	return ctx.c_tag(4)
}

// Convert value `js_object` to json string with optionals.
@[manualfree]
pub fn (ctx &Context) json_stringify_op(val Value, rep Value, ind AnyValue) string {
	indent := ctx.any_to_val(ind)
	ref := C.JS_JSONStringify(ctx.ref, val.ref, rep.ref, indent.ref)
	ptr := C.JS_ToCString(ctx.ref, ref)
	ret := v_str(ptr)
	C.JS_FreeCString(ctx.ref, ptr)
	return ret
}

// Convert value `js_object` to json string.
pub fn (ctx &Context) json_stringify(val Value) string {
	null := ctx.js_null()
	return ctx.json_stringify_op(val, null, null)
}

// Convert value string to `js_object`.
@[manualfree]
pub fn (ctx &Context) json_parse(str string) Value {
	len := str.len
	c_str := str.str
	c_fname := ''.str
	ret := ctx.c_val(C.JS_ParseJSON(ctx.ref, c_str, usize(len), c_fname))
	unsafe {
		free(c_fname)
		free(c_str)
	}
	return ret
}

// JS Throw Error.
pub fn (ctx &Context) js_throw(any AnyValue) Value {
	val := ctx.any_to_val(any)
	return ctx.c_val(C.JS_Throw(ctx.ref, val.ref))
}

// create JS new Error.
pub fn (ctx &Context) js_error(err JSError) Value {
	val := ctx.c_val(C.JS_NewError(ctx.ref))
	val.set('name', ctx.js_string(err.name))
	val.set('message', ctx.js_string(err.message))
	if err.stack != '' {
		val.set('stack', ctx.js_string(err.stack))
	}
	return val
}

// create JS new TypeError.
pub fn (ctx &Context) js_type_error(err JSError) Value {
	mut terr := err
	terr.name = 'TypeError'
	return ctx.js_error(terr)
}

// js dump IError.
pub fn (ctx &Context) js_dump(err IError) Value {
	val := ctx.c_val(C.JS_NewError(ctx.ref))
	val.set('message', ctx.js_string(err.msg()))
	return val
}

// Create JS String.
@[manualfree]
pub fn (ctx &Context) js_string(data string) Value {
	ptr := data.str
	val := ctx.c_val(C.JS_NewString(ctx.ref, ptr))
	unsafe {
		free(ptr)
	}
	return val
}

// Create JS Boolean.
pub fn (ctx &Context) js_bool(data bool) Value {
	return ctx.c_val(C.JS_NewBool(ctx.ref, if data { 1 } else { 0 }))
}

// Create JS Int.
pub fn (ctx &Context) js_int(data int) Value {
	return ctx.c_val(C.JS_NewInt32(ctx.ref, data))
}

// Create JS u32.
pub fn (ctx &Context) js_u32(data u32) Value {
	return ctx.c_val(C.JS_NewUint32(ctx.ref, data))
}

// Create JS Bigint.
pub fn (ctx &Context) js_big_int(data i64) Value {
	return ctx.c_val(C.JS_NewBigInt64(ctx.ref, data))
}

// Create JS ArrayBuffer.
pub fn (ctx &Context) js_array_buffer(data []u8) Value {
	return ctx.c_val(C.JS_NewArrayBufferCopy(ctx.ref, &data[0], usize(data.len)))
}

// Create JS Big Uint.
pub fn (ctx &Context) js_big_uint(data u64) Value {
	return ctx.c_val(C.JS_NewBigUint64(ctx.ref, data))
}

// Create JS int64.
pub fn (ctx &Context) js_i64(data i64) Value {
	return ctx.c_val(C.JS_NewInt64(ctx.ref, data))
}

// Create JS Float.
pub fn (ctx &Context) js_float(data f64) Value {
	return ctx.c_val(C.JS_NewFloat64(ctx.ref, data))
}

// Create JS Object.
pub fn (ctx &Context) js_object() Value {
	return ctx.c_val(C.JS_NewObject(ctx.ref))
}

// Define JS Global (globalThis).
@[manualfree]
pub fn (ctx &Context) js_global(keys ...string) Value {
	if keys.len == 0 {
		return ctx.c_val(C.JS_GetGlobalObject(ctx.ref))
	}
	glob := ctx.js_global()
	ret := glob.get(keys[0])
	glob.free()
	return ret
}

// JS call await.
pub fn (ctx &Context) js_await(val Value) !Value {
	dup := val.dup_value()
	ret := ctx.c_val(C.js_std_await(ctx.ref, dup.ref))
	if ret.is_exception() {
		return ctx.js_exception()
	}
	return ret
}

// JS call new class.
pub fn (ctx &Context) js_new_class(val Value, args ...AnyValue) !Value {
	c_args := args.map(ctx.any_to_val(it).ref)
	c_val := if c_args.len == 0 { unsafe { nil } } else { &c_args[0] }
	ret := ctx.c_val(C.JS_CallConstructor(ctx.ref, val.ref, c_args.len, c_val))
	if ret.is_exception() {
		return ctx.js_exception()
	}
	return ret
}

// Convert any to value.
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

// Create JS Array.
pub fn (ctx &Context) js_array() Value {
	return ctx.c_val(C.JS_NewArray(ctx.ref))
}
