import vjs { Value }
import os

fn main() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()

	global := ctx.js_global()
	global.set('readFile', ctx.js_function(fn [ctx] (args []Value) Value {
		mut error := ctx.js_undefined()
		promise := ctx.js_promise()
		if args.len == 0 {
			error = ctx.js_error(message: 'path is required', name: 'TypeError')
			unsafe {
				goto reject
			}
		}
		path := args[0]
		file := os.read_file(path.str()) or {
			error = ctx.js_error(message: err.msg())
			unsafe {
				goto reject
			}
			''
		}
		return promise.resolve(file)
		reject:
		return promise.reject(error)
	}))

	code := '		
		readFile("fib.v").then((text) => {
			console.log(text);
		}).catch((err) => {
			console.log(err);
		})
	'
	value := ctx.eval(code, vjs.type_module) or { panic(err) }

	// free
	global.free()
	value.free()
	ctx.free()
	rt.free()
}
