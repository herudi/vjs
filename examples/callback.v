import vjs { Value }

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
				val_from_fn := val.callback('baz') or { panic(err) }
				return val_from_fn.str()
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
	println('result => ${value}')

	// free
	value.free()
	global.free()
	ctx.free()
	rt.free()
}
