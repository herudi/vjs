module web

import vjs { Context }
import os
import runtime
import v.vmod

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
	uname := os.uname()
	manifest := vmod.from_file('${@VMODROOT}/v.mod') or { panic(err) }
	obj := ctx.js_object()
	obj.set('userAgent', '${manifest.name}/${manifest.version}')
	obj.set('platform', '${uname.sysname} ${uname.machine}')
	obj.set('hardwareConcurrency', runtime.nr_cpus())
	glob := ctx.js_global()
	glob.set('__navigator', obj)
	ctx.eval_file('${@VMODROOT}/web/js/navigator.js', vjs.type_module) or { panic(err) }
	glob.delete('__navigator')
	glob.free()
}
