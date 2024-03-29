import herudi.vjs { Value }

fn main() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()

	global := ctx.js_global()
	global.set('my_fn', ctx.js_function(fn [ctx] (args []Value) Value {
		if args.len == 0 {
			return ctx.js_undefined()
		}
		return ctx.js_string(args.map(fn (val Value) string {
			if val.is_function() {
				return val.callback('baz').str()
			}
			return val.str()
		}).join(','))
	}))

	code := '
		my_fn("foo", "bar", (param) => {
			return param;
		})
	'

	value := ctx.eval(code) or { panic(err) }
	ctx.end()

	println('result => ${value}')

	// free
	value.free()
	global.free()
	ctx.free()
	rt.free()
}
