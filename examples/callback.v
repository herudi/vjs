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

	global := ctx.js_global()
	defer {
		global.free()
	}

	global.set('my_fn', ctx.js_callback(fn (ctx &Context, args []Value) Value {
		println('arguments => ${args}')
		if args.len == 0 {
			return ctx.js_undefined()
		}
		return ctx.js_string(args.map(it.str()).join(','))
	}))

	value := ctx.eval('my_fn("foo", "bar", "baz")') or { panic(err) }
	defer {
		value.free()
	}

	println('result => ${value}')
}
