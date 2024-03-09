import vjs { Value }

fn test_type() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()

	obj := ctx.js_object()
	obj.set('foo', 'foo')
	assert obj.is_object() == true
	assert obj.get('foo').str() == 'foo'
	assert ctx.json_stringify(obj) == '{"foo":"foo"}'
	assert ctx.json_parse('{"foo":"foo"}').get('foo').str() == 'foo'

	arr := ctx.js_array()
	arr.call('push', 'foo')
	assert arr.is_array() == true
	assert arr.get(0).str() == 'foo'

	str := ctx.js_string('foo')
	assert str.str() == 'foo'

	numb := ctx.js_int(1)
	assert numb.to_int() == 1

	null := ctx.js_null()
	assert null.is_null() == true

	undefined := ctx.js_undefined()
	assert undefined.is_undefined() == true

	uninitialized := ctx.js_uninitialized()
	assert uninitialized.is_uninitialized() == true

	boolean := ctx.js_bool(true)
	assert boolean.is_bool() == true

	bigint := ctx.js_big_int(10000000000000)
	assert bigint.is_number() == false
	assert bigint.is_big_int() == true

	ctx.js_throw(ctx.js_error(message: 'error message'))
	assert ctx.js_exception().msg() == 'Error: error message\n'

	ctx.js_throw(ctx.js_type_error(message: 'error message'))
	assert ctx.js_exception().msg() == 'TypeError: error message\n'

	ctx.js_throw(ctx.js_error(message: 'error message', name: 'CustomError'))
	assert ctx.js_exception().msg() == 'CustomError: error message\n'

	arr_buf := ctx.js_array_buffer('foo'.bytes())
	assert arr_buf.instanceof('ArrayBuffer') == true

	any_str := ctx.any_to_val('foo')
	assert any_str.str() == 'foo'

	cb := ctx.js_function(fn [ctx] (args []Value) Value {
		return ctx.js_null()
	})
	assert cb.is_function() == true

	ctx.free()
	rt.free()
}
