module web

import vjs { Context, Value }

fn console_boot(ctx &Context, boot Value) {
	boot.set('print', ctx.js_function(fn [ctx] (args []Value) Value {
		println(args.map(it.str()).join(' '))
		return ctx.js_undefined()
	}))
	boot.set('promise_state', ctx.js_function(fn [ctx] (args []Value) Value {
		return ctx.promise_state(args[0])
	}))
}

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
	create_util(ctx)
	glob, boot := get_bootstrap(ctx)
	console_boot(ctx, boot)
	ctx.eval_file('${@VMODROOT}/web/js/console.js', vjs.type_module) or { panic(err) }
	glob.free()
}
