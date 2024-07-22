module web

import vjs { Context, JSFunctionThis, Value }

type FnWrapBool = fn (this Value, args []Value) bool

fn is_object(this Value, args []Value) Value {
	val := args[0]
	if val.is_undefined() || val.is_null() {
		return this.ctx.js_bool(false)
	}
	ctor := val.get('constructor')
	if ctor.is_undefined() || ctor.is_null() {
		return this.ctx.js_bool(false)
	}
	return this.ctx.js_bool(ctor.get('name').str() == 'Object')
}

fn is_type_object(this Value, args []Value) Value {
	return this.ctx.js_bool(args[0].is_object())
}

fn is_array(this Value, args []Value) Value {
	return this.ctx.js_bool(args[0].is_array())
}

fn is_string(this Value, args []Value) Value {
	return this.ctx.js_bool(args[0].is_string())
}

fn is_number(this Value, args []Value) Value {
	return this.ctx.js_bool(args[0].is_number())
}

fn is_bool(this Value, args []Value) Value {
	return this.ctx.js_bool(args[0].is_bool())
}

fn is_func(this Value, args []Value) Value {
	return this.ctx.js_bool(args[0].is_function())
}

fn is_regexp(this Value, args []Value) Value {
	return this.ctx.js_bool(args[0].instanceof('RegExp'))
}

fn is_array_buffer(this Value, args []Value) Value {
	return this.ctx.js_bool(args[0].instanceof('ArrayBuffer'))
}

fn is_promise(this Value, args []Value) Value {
	return this.ctx.js_bool(args[0].instanceof('Promise'))
}

fn is_typed_array(this Value, args []Value) bool {
	val := args[0]
	buf := this.ctx.js_global('ArrayBuffer')
	call_is_view := buf.call('isView', val)
	is_view := call_is_view.to_bool()
	is_data_view := val.instanceof('DataView')
	return is_view && !is_data_view
}

fn is_date(this Value, args []Value) Value {
	return this.ctx.js_bool(args[0].instanceof('Date'))
}

fn is_redirect(this Value, args []Value) Value {
	code := args[0].to_int()
	return this.ctx.js_bool(code == 301 || code == 302 || code == 303 || code == 307 || code == 308)
}

fn wrap_bool(cb FnWrapBool) JSFunctionThis {
	return fn [cb] (this Value, args []Value) Value {
		return this.ctx.js_bool(cb(this, args))
	}
}

fn util_boot(ctx &Context, boot Value) {
	obj := ctx.js_object()
	obj.set('isObject', ctx.js_function_this(is_object))
	obj.set('isTypeObject', ctx.js_function_this(is_type_object))
	obj.set('isArray', ctx.js_function_this(is_array))
	obj.set('isString', ctx.js_function_this(is_string))
	obj.set('isNumber', ctx.js_function_this(is_number))
	obj.set('isBool', ctx.js_function_this(is_bool))
	obj.set('isFunc', ctx.js_function_this(is_func))
	obj.set('isRegExp', ctx.js_function_this(is_regexp))
	obj.set('isArrayBuffer', ctx.js_function_this(is_array_buffer))
	obj.set('isPromise', ctx.js_function_this(is_promise))
	obj.set('isTypedArray', ctx.js_function_this(wrap_bool(is_typed_array)))
	obj.set('isDate', ctx.js_function_this(is_date))
	obj.set('isRedirect', ctx.js_function_this(is_redirect))
	boot.set('util', obj)
}

fn create_util(ctx &Context) {
	glob, boot := get_bootstrap(ctx)
	util_boot(ctx, boot)
	glob.free()
}
