import vjs

fn test_eval() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()

	value := ctx.eval('1 + 2') or { panic(err) }
	ctx.end()

	assert value.is_number() == true
	assert value.is_string() == false
	assert value.to_int() == 3

	// free
	value.free()
	ctx.free()
	rt.free()
}

fn test_multi_eval() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()

	ctx.eval('const sum = (a, b) => a + b') or { panic(err) }
	ctx.eval('const mul = (a, b) => a * b') or { panic(err) }

	sum := ctx.eval('sum(${1}, ${2})') or { panic(err) }
	mul := ctx.eval('mul(${1}, ${2})') or { panic(err) }

	ctx.end()

	assert sum.to_int() == 3
	assert mul.to_int() == 2

	// free
	mul.free()
	sum.free()
	ctx.free()
	rt.free()
}
