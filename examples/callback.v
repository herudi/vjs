import vjs { Context, Value }

fn main() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()

	global := ctx.js_global()
	global.set('my_fn', ctx.js_callback(fn (ctx &Context, this Value, args []Value) Value {
		println('arguments => ${args}')
		if args.len == 0 {
			return ctx.js_undefined()
		}
		return ctx.js_string(args.map(it.str()).join(','))
	}))

	value := ctx.eval('my_fn("foo", "bar", "baz")') or { panic(err) }
	println('result => ${value}')

	// free
	value.free()
	global.free()
	ctx.free()
	rt.free()
}
