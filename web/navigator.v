module web

import vjs { Context }
import os
import runtime

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
	version := os.read_file('${@VMODROOT}/VERSION') or { panic(err) }
	uname := os.uname()
	obj := ctx.js_object()
	obj.set('version', version)
	obj.set('platform', '${uname.sysname} ${uname.machine}')
	obj.set('nr_cpu', runtime.nr_cpus())
	glob := ctx.js_global()
	glob.set('__navigator', obj)
	ctx.eval_file('${@VMODROOT}/web/js/navigator.js', vjs.type_module) or { panic(err) }
	glob.delete('__navigator')
	glob.free()
}
