import vjs

fn test_typeof() {
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
			h: Symbol("foo"),
			i: () => {},
			j: Promise.resolve("foo")
		}
	})()'
	val := ctx.eval(code) or { panic(err) }
	ctx.end()
	assert val.get('a').is_number() == true
	assert val.get('b').is_string() == true
	assert val.get('c').is_bool() == true
	assert val.get('d').is_object() == true
	assert val.get('e').is_array() == true
	assert val.get('f').is_null() == true
	assert val.get('g').is_undefined() == true
	assert val.get('h').is_symbol() == true
	assert val.get('i').is_function() == true
	assert val.get('j').instanceof('Promise') == true
	assert val.get('a').typeof_name() == 'number'
	val.free()
	ctx.free()
	rt.free()
}
