module web

import vjs { Context, Value }

// Add console to globals.
// Example:
// ```v
// import herudi.vjs
// import herudi.vjs.web
//
// fn main() {
//   rt := vjs.new_runtime()
//   ctx := rt.new_context()
//
//   web.console_api(ctx)
// }
// ```
@[manualfree]
pub fn console_api(ctx &Context) {
	glob := ctx.js_global()
	glob.set('__print', ctx.js_function(fn [ctx] (args []Value) Value {
		println(args.map(it.str()).join(' '))
		return ctx.js_undefined()
	}))
	ctx.eval_file('${@VMODROOT}/web/js/console.js', vjs.type_module) or { panic(err) }
	glob.delete('__print')
	glob.free()
}
