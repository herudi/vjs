module web

import vjs { Context }

// Add timer API to globals (`setTimeout`, `setInterval`, `clearTimeout`, `clearInterval`).
// Example:
// ```v
// import herudi.vjs
// import herudi.vjs.web
//
// fn main() {
//   rt := vjs.new_runtime()
//   ctx := rt.new_context()
//
//   web.timer_api(ctx)
// }
// ```
pub fn timer_api(ctx &Context) {
	ctx.eval_file('${@VMODROOT}/web/js/timer.js', vjs.type_module) or { panic(err) }
}
