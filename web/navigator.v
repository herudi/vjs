module web

import vjs { Context, Value }
import os
import runtime
import v.vmod

fn navigator_boot(ctx &Context, boot Value) {
	boot.set('get_navigator', ctx.js_function(fn [ctx] (args []Value) Value {
		uname := os.uname()
		manifest := vmod.from_file('${@VMODROOT}/v.mod') or { panic(err) }
		obj := ctx.js_object()
		obj.set('userAgent', '${manifest.name}/${manifest.version}')
		obj.set('platform', '${uname.sysname} ${uname.machine}')
		obj.set('hardwareConcurrency', runtime.nr_cpus())
		return obj
	}))
}

// Add Navigator API to globals.
// Example:
// ```v
// import herudi.vjs
// import herudi.vjs.web
//
// fn main() {
//   rt := vjs.new_runtime()
//   ctx := rt.new_context()
//
//   web.navigator_api(ctx)
// }
// ```
pub fn navigator_api(ctx &Context) {
	glob, boot := get_bootstrap(ctx)
	navigator_boot(ctx, boot)
	ctx.eval_file('${@VMODROOT}/web/js/navigator.js', vjs.type_module) or { panic(err) }
	glob.free()
}
