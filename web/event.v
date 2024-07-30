module web

import vjs { Context }

// Add EventTarget API to globals
// Example:
// ```v
// import herudi.vjs
// import herudi.vjs.web
//
// fn main() {
//   rt := vjs.new_runtime()
//   ctx := rt.new_context()
//
//   web.event_api(ctx)
// }
// ```
pub fn event_api(ctx &Context) {
	ctx.eval_file('${@VMODROOT}/web/js/event.js', vjs.type_module) or { panic(err) }
}
