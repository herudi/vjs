import vjs

fn test_value() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()

	code := '(() => {
		return {
			a: 1,
			b: "b",
			c: false,
			d: {},
			e: [],
			f: null,
			g: undefined,
			i: () => "foo",
			j: Promise.resolve("foo")
		}
	})()'
	val := ctx.eval(code) or { panic(err) }
	ctx.end()
	assert val.get('a').to_int() == 1
	assert val.get('a').to_i64() == i64(1)
	assert val.get('a').to_u32() == u32(1)
	assert val.get('b').to_string() == 'b'
	assert val.get('c').to_bool() == false
	assert val.get('d').json_stringify() == '{}'
	assert val.get('e').json_stringify() == '[]'
	assert val.get('f').to_string() == 'null'
	assert val.get('g').to_string() == 'undefined'
	assert val.get('i').callback().str() == 'foo'
	assert val.get('j').await().str() == 'foo'
	val.free()
	ctx.free()
	rt.free()
}
