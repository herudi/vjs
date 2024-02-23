import vjs { Context }

fn type_number(ctx Context) {
	code := '(() => {
		return 1 + 2
	})()'
	val := ctx.eval(code) or { panic(err) }
	assert val.is_number() == true
	assert val.is_string() == false
	assert val.int() == 3
	assert val.str() == '3'
	assert val.typeof_name() == 'number'
	println('Number => ${val}')
	val.free()
	ctx.free()
}

fn type_bool(ctx Context) {
	code := '(() => {
		return true
	})()'
	val := ctx.eval(code) or { panic(err) }
	assert val.is_bool() == true
	assert val.bool() == true
	assert val.typeof_name() == 'boolean'
	println('Bool => ${val}')
	val.free()
	ctx.free()
}

fn type_object(ctx Context) {
	code := '(() => {
		return { name: "john" }
	})()'
	val := ctx.eval(code) or { panic(err) }
	assert val.is_object() == true
	assert val.json_stringify() == '{"name":"john"}'
	assert val.typeof_name() == 'object'
	println('Object => ${val.json_stringify()}')
	val.free()
	ctx.free()
}

fn type_array(ctx Context) {
	code := '(() => {
		return [1, 2]
	})()'
	val := ctx.eval(code) or { panic(err) }
	assert val.is_array() == true
	assert val.json_stringify() == '[1,2]'
	assert val.typeof_name() == 'object'
	println('Array => ${val.json_stringify()}')
	val.free()
	ctx.free()
}

fn main() {
	rt := vjs.new_runtime()

	type_number(rt.new_context())
	type_bool(rt.new_context())
	type_object(rt.new_context())
	type_array(rt.new_context())

	rt.free()
}
