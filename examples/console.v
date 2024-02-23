import vjs { Context, Value }

fn main() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()

	console := ctx.js_object()
	console.set('log', ctx.js_callback(fn (ctx &Context, this Value, args []Value) Value {
		println(args.map(it.str()).join(' '))
		return ctx.js_undefined()
	}))

	global := ctx.js_global()
	global.set('console', console)
	value := ctx.eval('console.log("foo", "bar", "baz")') or { panic(err) }

	// free
	value.free()
	global.free()
	console.free()
	ctx.free()
	rt.free()
}
