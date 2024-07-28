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

// Value structure based on `JSValue` in qjs
// and implemented into `ref`.
pub struct Value {
	ref C.JSValue
pub:
	ctx Context
}

// `type` property keys. to use get/set values.
pub type PropKey = Atom | PropertyEnum | int | string

// `type` JSValueConst. this type is free.
pub type JSValueConst = C.JSValue

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
fn C.JS_SetPropertyUint32(&C.JSContext, JSValueConst, u32, C.JSValue) int
fn C.JS_SetProperty(&C.JSContext, JSValueConst, C.JSAtom, C.JSValue) int
fn C.JS_GetPropertyStr(&C.JSContext, JSValueConst, &char) C.JSValue
fn C.JS_GetPropertyUint32(&C.JSContext, JSValueConst, u32) C.JSValue
fn C.JS_GetProperty(&C.JSContext, JSValueConst, C.JSAtom) C.JSValue
fn C.JS_Call(&C.JSContext, JSValueConst, JSValueConst, int, &JSValueConst) C.JSValue
fn C.JS_DupValue(&C.JSContext, JSValueConst) C.JSValue
fn C.JS_GetArrayBuffer(&C.JSContext, &usize, JSValueConst) byteptr
fn C.JS_DeleteProperty(&C.JSContext, JSValueConst, C.JSAtom, int) int
fn C.JS_HasProperty(&C.JSContext, JSValueConst, C.JSAtom) int

// Duplicate value
pub fn (v Value) dup_value() Value {
	return v.ctx.c_val(C.JS_DupValue(v.ctx.ref, v.ref))
}

// Convert Value to `V` String
@[manualfree]
pub fn (v Value) to_string() string {
	ptr := C.JS_ToCString(v.ctx.ref, v.ref)
	ret := if isnil(ptr) {
		if v.is_array() {
			return '[]'
		}
		if v.is_object() {
			return '{}'
		}
		return v.ctx.js_undefined().str()
	} else {
		v_str(ptr)
	}
	C.JS_FreeCString(v.ctx.ref, ptr)
	return ret
}

// Convert Value to `V` []u8
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

// Convert Value to `V` String
pub fn (v Value) str() string {
	return v.to_string()
}

// Convert Value object to `V` string json
pub fn (v Value) json_stringify() string {
	return v.ctx.json_stringify(v)
}

// Convert Value to `V` JSError
@[manualfree]
pub fn (v Value) to_error() &JSError {
	if !v.is_error() {
		return &JSError{}
	}
	message := v.to_string()
	name := v.get('name')
	stack := v.get('stack')
	err := &JSError{
		name: if name.is_undefined() { '' } else { name.to_string() }
		message: message
		stack: if stack.is_undefined() { '' } else { stack.to_string() }
	}
	stack.free()
	name.free()
	return err
}

// Convert Value to `V` bool
pub fn (v Value) to_bool() bool {
	return C.JS_ToBool(v.ctx.ref, v.ref)
}

// Convert Value to `V` int
pub fn (v Value) to_int() int {
	mut val := 0
	C.JS_ToInt32(v.ctx.ref, &val, v.ref)
	return val
}

// Convert Value to `V` i64
pub fn (v Value) to_i64() i64 {
	mut val := i64(0)
	C.JS_ToInt64(v.ctx.ref, &val, v.ref)
	return val
}

// Convert Value to `V` u32
pub fn (v Value) to_u32() u32 {
	mut val := u32(0)
	C.JS_ToUint32(v.ctx.ref, &val, v.ref)
	return val
}

// Convert Value to `V` f64
pub fn (v Value) to_f64() f64 {
	mut val := f64(0)
	C.JS_ToFloat64(v.ctx.ref, &val, v.ref)
	return val
}

// Set property
// Example:
// ```v
// obj := ctx.js_object()
// obj.set('foo', 'foo')
// ```
@[manualfree]
pub fn (v Value) set(key PropKey, any AnyValue) {
	val := v.ctx.any_to_val(any)
	if key is string {
		ptr := key.str
		C.JS_SetPropertyStr(v.ctx.ref, v.ref, ptr, val.ref)
		unsafe {
			free(ptr)
		}
	} else if key is Atom {
		C.JS_SetProperty(v.ctx.ref, v.ref, key.ref, val.ref)
	} else if key is PropertyEnum {
		C.JS_SetProperty(v.ctx.ref, v.ref, key.atom.ref, val.ref)
	} else if key is int {
		C.JS_SetPropertyUint32(v.ctx.ref, v.ref, u32(key), val.ref)
	}
}

// Get property
// Example:
// ```v
// foo := obj.get('foo')
// ```
@[manualfree]
pub fn (v Value) get(key PropKey) Value {
	if key is string {
		ptr := key.str
		val := v.ctx.c_val(C.JS_GetPropertyStr(v.ctx.ref, v.ref, ptr))
		unsafe {
			free(ptr)
		}
		return val
	}
	if key is Atom {
		return v.ctx.c_val(C.JS_GetProperty(v.ctx.ref, v.ref, key.ref))
	}
	if key is int {
		return v.ctx.c_val(C.JS_GetPropertyUint32(v.ctx.ref, v.ref, u32(key)))
	}
	prop := key as PropertyEnum
	return v.ctx.c_val(C.JS_GetProperty(v.ctx.ref, v.ref, prop.atom.ref))
}

fn (v Value) get_atom(key PropKey) Atom {
	return if key is string {
		v.ctx.new_atom(key)
	} else if key is PropertyEnum {
		key.atom
	} else if key is int {
		v.ctx.new_atom(key)
	} else {
		key as Atom
	}
}

// Delete property
// Example:
// ```v
// obj.delete('foo')
// ```
@[manualfree]
pub fn (v Value) delete(key PropKey) bool {
	atom := v.get_atom(key)
	ret := C.JS_DeleteProperty(v.ctx.ref, v.ref, atom.ref, 1) == 1
	atom.free()
	return ret
}

// Has property
// Example:
// ```v
// has := obj.has('foo')
// ```
@[manualfree]
pub fn (v Value) has(key PropKey) bool {
	atom := v.get_atom(key)
	ret := C.JS_HasProperty(v.ctx.ref, v.ref, atom.ref) == 1
	atom.free()
	return ret
}

// Length value
pub fn (v Value) len() int {
	return v.get('length').to_int()
}

// byteLength value
pub fn (v Value) byte_len() int {
	return v.get('byteLength').to_int()
}

// Awaited from Promise
// Example:
// ```v
// val := my_promise.await()
// ```
pub fn (v Value) await() Value {
	return v.ctx.js_await(v) or { panic(err) }
}

// Callback function self
// Example:
// ```v
// val := my_fn.callback(...args)
// ```
pub fn (v Value) callback(args ...AnyValue) Value {
	return v.ctx.call(v, ...args) or { panic(err) }
}

// New from classes
// Example:
// ```v
// val := my_class.new(...args)
// ```
pub fn (v Value) new(args ...AnyValue) Value {
	return v.ctx.js_new_class(v, ...args) or { panic(err) }
}

// Call fn.
// Example:
// ```v
// array.call('push', ...args)
// ```
@[manualfree]
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
	c_val := if c_vals.len == 0 { unsafe { nil } } else { &c_vals[0] }
	ret := v.ctx.c_val(C.JS_Call(v.ctx.ref, data.ref, v.ref, c_vals.len, c_val))
	defer {
		ret.free()
	}
	if ret.is_exception() {
		return v.ctx.js_string(v.ctx.js_exception().msg())
	}
	return ret
}

// Free Value
pub fn (v &Value) free() {
	C.JS_FreeValue(v.ctx.ref, v.ref)
}
