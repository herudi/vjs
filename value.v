module vjs

@[typedef]
union C.JSValueUnion {
	int32   int
	float64 f64
	ptr     voidptr
}

@[typedef]
struct C.JSValue {
	u   C.JSValueUnion
	tag i64
}

type GetSet = Atom | PropertyEnum | string
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
fn C.JS_SetProperty(&C.JSContext, JSValueConst, C.JSAtom, C.JSValue) int
fn C.JS_GetPropertyStr(&C.JSContext, JSValueConst, &char) C.JSValue
fn C.JS_GetProperty(&C.JSContext, JSValueConst, C.JSAtom) C.JSValue
fn C.JS_Call(&C.JSContext, JSValueConst, JSValueConst, int, &JSValueConst) C.JSValue
fn C.JS_DupValue(&C.JSContext, JSValueConst) C.JSValue
fn C.JS_GetArrayBuffer(&C.JSContext, &usize, JSValueConst) byteptr

pub fn (v Value) dup_value() Value {
	return v.ctx.c_val(C.JS_DupValue(v.ctx.ref, v.ref))
}

pub fn (v Value) to_string() string {
	ptr := C.JS_ToCString(v.ctx.ref, v.ref)
	C.JS_FreeCString(v.ctx.ref, ptr)
	u_free(ptr)
	return v_str(ptr)
}

pub fn (v Value) to_bytes() []u8 {
	len := v.byte_len()
	size := usize(len)
	data := C.JS_GetArrayBuffer(v.ctx.ref, &size, v.ref)
	mut bytes := []u8{cap: len}
	for i in 0 .. len {
		bytes << unsafe { data[i] }
	}
	return bytes
}

pub fn (v Value) str() string {
	return v.to_string()
}

pub fn (v Value) json_stringify() string {
	return v.ctx.json_stringify(v)
}

pub fn (v Value) to_error() &JSError {
	message := v.to_string()
	stack := v.get('stack')
	err := &JSError{
		message: message
		stack: if stack.is_undefined() { '' } else { stack.to_string() }
	}
	stack.free()
	return err
}

pub fn (v Value) to_bool() bool {
	return C.JS_ToBool(v.ctx.ref, v.ref)
}

pub fn (v Value) to_int() int {
	mut val := 0
	C.JS_ToInt32(v.ctx.ref, &val, v.ref)
	return val
}

pub fn (v Value) to_i64() i64 {
	mut val := i64(0)
	C.JS_ToInt64(v.ctx.ref, &val, v.ref)
	return val
}

pub fn (v Value) to_u32() u32 {
	mut val := u32(0)
	C.JS_ToUint32(v.ctx.ref, &val, v.ref)
	return val
}

pub fn (v Value) to_f64() f64 {
	mut val := f64(0)
	C.JS_ToFloat64(v.ctx.ref, &val, v.ref)
	return val
}

pub fn (v Value) set(key GetSet, any AnyValue) {
	val := v.ctx.any_to_val(any)
	if key is string {
		C.JS_SetPropertyStr(v.ctx.ref, v.ref, u_free(key.str), val.ref)
	} else if key is Atom {
		C.JS_SetProperty(v.ctx.ref, v.ref, key.ref, val.ref)
	} else if key is PropertyEnum {
		C.JS_SetProperty(v.ctx.ref, v.ref, key.atom.ref, val.ref)
	}
}

pub fn (v Value) get(key GetSet) Value {
	if key is string {
		return v.ctx.c_val(C.JS_GetPropertyStr(v.ctx.ref, v.ref, u_free(key.str)))
	}
	if key is Atom {
		return v.ctx.c_val(C.JS_GetProperty(v.ctx.ref, v.ref, key.ref))
	}
	prop := key as PropertyEnum
	return v.ctx.c_val(C.JS_GetProperty(v.ctx.ref, v.ref, prop.atom.ref))
}

pub fn (v Value) len() int {
	return v.get('length').to_int()
}

pub fn (v Value) byte_len() int {
	return v.get('byteLength').to_int()
}

pub fn (v Value) await() !Value {
	val := v.ctx.c_val(C.js_std_await(v.ctx.ref, v.ref))
	if val.is_exception() {
		return v.ctx.js_exception()
	}
	return val
}

pub fn (v Value) callback(args ...AnyValue) !Value {
	if !v.is_function() {
		return &JSError{
			message: 'Value is not a function'
		}
	}
	return v.ctx.call(v, ...args)
}

pub fn (v Value) call(key string, args ...AnyValue) Value {
	if !v.is_object() {
		return v.ctx.js_error(message: 'Value is not Object')
	}
	data := v.get(key)
	defer {
		data.free()
	}
	if !data.is_function() {
		return v.ctx.js_error(message: 'Value is not Function')
	}
	c_vals := args.map(v.ctx.any_to_val(it).ref)
	c_ptr := if c_vals.len == 0 { unsafe { nil } } else { &c_vals[0] }
	u_free(c_ptr)
	ret := v.ctx.c_val(C.JS_Call(v.ctx.ref, data.ref, v.ref, c_vals.len, c_ptr))
	defer {
		ret.free()
	}
	if ret.is_exception() {
		return v.ctx.js_string(v.ctx.js_exception().msg())
	}
	return ret
}

@[manualfree]
pub fn (v &Value) free() {
	C.JS_FreeValue(v.ctx.ref, v.ref)
}
