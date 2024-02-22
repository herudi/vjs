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
fn C.JS_IsException(JSValueConst) int
fn C.JS_JSONStringify(&C.JSContext, JSValueConst, JSValueConst, JSValueConst) C.JSValue

pub fn (v &Value) str() string {
	ptr := C.JS_ToCString(v.ctx.ref, v.ref)
	C.JS_FreeCString(v.ctx.ref, ptr)
	return unsafe { cstring_to_vstring(ptr) }
}

pub fn (v &Value) json_stringify() string {
	null := v.ctx.js_null().ref
	json := C.JS_JSONStringify(v.ctx.ref, v.ref, null, null)
	ptr := C.JS_ToCString(v.ctx.ref, json)
	C.JS_FreeCString(v.ctx.ref, ptr)
	return unsafe { cstring_to_vstring(ptr) }
}

pub fn (v &Value) to_error() &JSError {
	return &JSError{
		message: v.str()
	}
}

pub fn (v &Value) is_exception() bool {
	return C.JS_IsException(v.ref) == 1
}

@[manualfree]
pub fn (v &Value) free() {
	C.JS_FreeValue(v.ctx.ref, v.ref)
}
