module web

import vjs { Context, Value }
import time

const offset = time.now().unix_nano()

fn performance_boot(ctx &Context, boot Value) {
	boot.set('perf_now', ctx.js_function(fn [ctx] (args []Value) Value {
		now := '${time.now().unix_nano() - web.offset}'
		return ctx.js_string('${now}')
	}))
}

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
	glob, boot := get_bootstrap(ctx)
	performance_boot(ctx, boot)
	ctx.eval_file('${@VMODROOT}/web/js/perf.js', vjs.type_module) or { panic(err) }
	glob.free()
}
