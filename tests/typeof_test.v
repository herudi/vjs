import vjs

fn test_type_number() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()
	code := '(() => {
		return 1 + 2
	})()'
	val := ctx.eval(code) or { panic(err) }
	ctx.end()
	assert val.is_number() == true
	assert val.is_string() == false
	assert val.to_int() == 3
	assert val.to_string() == '3'
	assert val.typeof_name() == 'number'
	val.free()
	ctx.free()
	rt.free()
}

fn test_type_bool() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()
	code := '(() => {
		return true
	})()'
	val := ctx.eval(code) or { panic(err) }
	ctx.end()
	assert val.is_bool() == true
	assert val.to_bool() == true
	assert val.typeof_name() == 'boolean'
	val.free()
	ctx.free()
	rt.free()
}

fn test_type_object() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()
	code := '(() => {
		return { name: "john" }
	})()'
	val := ctx.eval(code) or { panic(err) }
	ctx.end()
	json := ctx.json_stringify(val)
	assert val.is_object() == true
	assert json == '{"name":"john"}'
	assert val.typeof_name() == 'object'
	val.free()
	ctx.free()
	rt.free()
}

fn test_type_array() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()
	code := '(() => {
		return [1, 2]
	})()'
	val := ctx.eval(code) or { panic(err) }
	ctx.end()
	json := ctx.json_stringify(val)
	assert val.is_array() == true
	assert json == '[1,2]'
	assert val.typeof_name() == 'object'
	val.free()
	ctx.free()
	rt.free()
}
