import vjs

fn main() {
	rt := vjs.new_runtime()
	defer {
		rt.free()
	}

	ctx := rt.new_context()
	defer {
		ctx.free()
	}

	global := ctx.js_global()
	defer {
		global.free()
	}

	global.set('foo', 'bar')

	value := ctx.eval('foo') or { panic(err) }
	defer {
		value.free()
	}

	println('result => ${value}')
	// result => bar
}
