module vjs

@[typedef]
union C.JSValueUnion {
	int32   int
	float64 f64
	ptr     voidptr
}

@[typedef]
struct C.JSValue {
	u   &C.JSValueUnion
	tag i64
}

type JSValueConst = C.JSValue

pub struct Value {
	ref C.JSValue
	ctx Context
}

fn C.JS_FreeValue(&C.JSContext, C.JSValue)
fn C.JS_ToCString(&C.JSContext, JSValueConst) &char
fn C.JS_FreeCString(&C.JSContext, &char)
fn C.JS_JSONStringify(&C.JSContext, JSValueConst, JSValueConst, JSValueConst) C.JSValue
fn C.JS_ToBool(&C.JSContext, JSValueConst) bool
fn C.JS_ToInt32(&C.JSContext, &int, JSValueConst)
fn C.JS_ToInt64(&C.JSContext, &i64, JSValueConst)
fn C.JS_ToUint32(&C.JSContext, &u32, JSValueConst)
fn C.JS_ToFloat64(&C.JSContext, &f64, JSValueConst)
fn C.JS_SetPropertyStr(&C.JSContext, JSValueConst, &char, C.JSValue) int
fn C.JS_GetPropertyStr(&C.JSContext, JSValueConst, &char) C.JSValue
fn C.JS_Call(&C.JSContext, JSValueConst, JSValueConst, int, &JSValueConst) C.JSValue

pub fn (v Value) string() string {
	ptr := C.JS_ToCString(v.ctx.ref, v.ref)
	C.JS_FreeCString(v.ctx.ref, ptr)
	u_free(ptr)
	return v_str(ptr)
}

pub fn (v Value) str() string {
	return if v.is_object() { v.json_stringify() } else { v.string() }
}

pub fn (v Value) json_stringify() string {
	null := v.ctx.js_null().ref
	json := C.JS_JSONStringify(v.ctx.ref, v.ref, null, null)
	ptr := C.JS_ToCString(v.ctx.ref, json)
	C.JS_FreeCString(v.ctx.ref, ptr)
	u_free(ptr)
	return v_str(ptr)
}

pub fn (v Value) error() &JSError {
	if !v.is_error() {
		return &JSError{
			is_err: false
		}
	}
	message := v.string()
	stack := v.get('stack')
	return &JSError{
		message: message
		stack: if stack.is_undefined() { '' } else { stack.string() }
	}
}

pub fn (v Value) bool() bool {
	return C.JS_ToBool(v.ctx.ref, v.ref)
}

pub fn (v Value) int() int {
	mut val := 0
	C.JS_ToInt32(v.ctx.ref, &val, v.ref)
	return val
}

pub fn (v Value) i64() i64 {
	mut val := i64(0)
	C.JS_ToInt64(v.ctx.ref, &val, v.ref)
	return val
}

pub fn (v Value) u32() u32 {
	mut val := u32(0)
	C.JS_ToUint32(v.ctx.ref, &val, v.ref)
	return val
}

pub fn (v Value) f64() f64 {
	mut val := f64(0)
	C.JS_ToFloat64(v.ctx.ref, &val, v.ref)
	return val
}

pub fn (v Value) set(key string, any AnyValue) {
	val := v.ctx.any_to_val(any)
	C.JS_SetPropertyStr(v.ctx.ref, v.ref, u_free(key.str), val.ref)
}

pub fn (v Value) get(key string) Value {
	return v.ctx.c_val(C.JS_GetPropertyStr(v.ctx.ref, v.ref, u_free(key.str)))
}

pub fn (v Value) len() i64 {
	return v.get('length').i64()
}

pub fn (v Value) call(key string, args ...AnyValue) Value {
	if !v.is_object() {
		return v.ctx.js_error(message: 'Value is not Object')
	}
	mut data := v.get(key)
	defer {
		data.free()
	}
	if !data.is_function() {
		return v.ctx.js_error(message: 'Value is not Function')
	}
	c_vals := args.map(v.ctx.any_to_val(it).ref)
	return v.ctx.c_val(C.JS_Call(v.ctx.ref, data.ref, v.ref, c_vals.len, &c_vals[0]))
}

@[manualfree]
pub fn (v &Value) free() {
	C.JS_FreeValue(v.ctx.ref, v.ref)
}
