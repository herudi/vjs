import vjs { Context, Value }

fn main() {
	rt := vjs.new_runtime()
	defer {
		rt.free()
	}

	ctx := rt.new_context()
	defer {
		ctx.free()
	}

	console := ctx.js_object()
	defer {
		console.free()
	}

	console.set('log', ctx.js_callback(fn (ctx &Context, args []Value) Value {
		println(args.map(it.str()).join(' '))
		return ctx.js_undefined()
	}))

	global := ctx.js_global()
	defer {
		global.free()
	}

	global.set('console', console)

	value := ctx.eval('console.log("foo", "bar", "baz")') or { panic(err) }
	defer {
		value.free()
	}
}
