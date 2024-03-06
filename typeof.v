module vjs

// Declare Type Is
fn C.JS_IsException(JSValueConst) int
fn C.JS_IsNumber(JSValueConst) int
fn C.JS_IsBool(JSValueConst) int
fn C.JS_IsNull(JSValueConst) int
fn C.JS_IsUndefined(JSValueConst) int
fn C.JS_IsUninitialized(JSValueConst) int
fn C.JS_IsString(JSValueConst) int
fn C.JS_IsSymbol(JSValueConst) int
fn C.JS_IsObject(JSValueConst) int
fn C.JS_IsArray(&C.JSContext, JSValueConst) int
fn C.JS_IsError(&C.JSContext, JSValueConst) int
fn C.JS_IsFunction(&C.JSContext, JSValueConst) int

// fn Type Is
pub fn (v Value) is_exception() bool {
	return C.JS_IsException(v.ref) == 1
}

pub fn (v Value) is_number() bool {
	return C.JS_IsNumber(v.ref) == 1
}

pub fn (v Value) is_bool() bool {
	return C.JS_IsBool(v.ref) == 1
}

pub fn (v Value) is_null() bool {
	return C.JS_IsNull(v.ref) == 1
}

pub fn (v Value) is_undefined() bool {
	return C.JS_IsUndefined(v.ref) == 1
}

pub fn (v Value) is_uninitialized() bool {
	return C.JS_IsUninitialized(v.ref) == 1
}

pub fn (v Value) is_string() bool {
	return C.JS_IsString(v.ref) == 1
}

pub fn (v Value) is_symbol() bool {
	return C.JS_IsSymbol(v.ref) == 1
}

pub fn (v Value) is_object() bool {
	return C.JS_IsObject(v.ref) == 1
}

pub fn (v Value) is_array() bool {
	return C.JS_IsArray(v.ctx.ref, v.ref) == 1
}

pub fn (v Value) is_error() bool {
	return C.JS_IsError(v.ctx.ref, v.ref) == 1
}

pub fn (v Value) is_function() bool {
	return C.JS_IsFunction(v.ctx.ref, v.ref) == 1
}

pub fn (v Value) is_promise() bool {
	return v.to_string() == '[object Promise]'
}

pub fn (v Value) typeof_name() string {
	if v.is_string() {
		return 'string'
	}
	if v.is_bool() {
		return 'boolean'
	}
	if v.is_number() {
		return 'number'
	}
	if v.is_function() {
		return 'function'
	}
	if v.is_symbol() {
		return 'symbol'
	}
	if v.is_undefined() || v.is_uninitialized() {
		return 'undefined'
	}
	return 'object'
}