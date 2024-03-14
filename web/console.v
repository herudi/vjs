module web

import vjs { Context, Value }

@[manualfree]
pub fn console_api(ctx &Context) {
	glob := ctx.js_global()
	glob.set('__print', ctx.js_function(fn [ctx] (args []Value) Value {
		println(args.map(it.str()).join(' '))
		return ctx.js_undefined()
	}))
	ctx.eval_file('${@VMODROOT}/web/js/console.js', vjs.type_module) or { panic(err) }
	glob.free()
}
