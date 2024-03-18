module web

import vjs { Context, Value }
import time

const navigator = time.now().unix_time_nano()

// Add Performance API to globals.
// Example:
// ```v
// import herudi.vjs
// import herudi.vjs.web
//
// fn main() {
//   rt := vjs.new_runtime()
//   ctx := rt.new_context()
//
//   web.performance_api(ctx)
// }
// ```
pub fn performance_api(ctx &Context) {
	obj := ctx.js_object()
	obj.set('v_now', ctx.js_function(fn [ctx] (args []Value) Value {
		now := '${time.now().unix_time_nano() - web.navigator}'
		return ctx.js_string('${now[0..2]}.${now[2..now.len]}')
	}))
	glob := ctx.js_global()
	glob.set('__perf', obj)
	ctx.eval_file('${@VMODROOT}/web/js/perf.js', vjs.type_module) or { panic(err) }
	glob.delete('__perf')
	glob.free()
}
