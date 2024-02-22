import vjs { Context }

fn type_number(ctx Context) Context {
	code := '(() => {
		return 1 + 2
	})()'
	val := ctx.eval(code) or { panic(err) }
	assert val.is_number() == true
	assert val.is_string() == false
	assert val.int() == 3
	assert val.str() == '3'
	println('Number => ${val}')
	val.free()
	ctx.free()
	return ctx
}

fn type_bool(ctx Context) Context {
	code := '(() => {
		return true
	})()'
	val := ctx.eval(code) or { panic(err) }
	assert val.is_bool() == true
	assert val.bool() == true
	println('Bool => ${val}')
	val.free()
	ctx.free()
	return ctx
}

fn type_object(ctx Context) Context {
	code := '(() => {
		return { name: "john" }
	})()'
	val := ctx.eval(code) or { panic(err) }
	assert val.is_object() == true
	assert val.json_stringify() == '{"name":"john"}'
	println('Object => ${val.json_stringify()}')
	val.free()
	ctx.free()
	return ctx
}

fn type_array(ctx Context) Context {
	code := '(() => {
		return [1, 2]
	})()'
	val := ctx.eval(code) or { panic(err) }
	assert val.is_array() == true
	assert val.json_stringify() == '[1,2]'
	println('Array => ${val.json_stringify()}')
	val.free()
	ctx.free()
	return ctx
}

fn main() {
	rt := vjs.new_runtime()

	type_number(rt.new_context())
	type_bool(rt.new_context())
	type_object(rt.new_context())
	type_array(rt.new_context())

	rt.free()
}
