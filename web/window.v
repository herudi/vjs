module web

import vjs { Context }

// Add Window API to globals. same as globalThis.
// Example:
// ```v
// import herudi.vjs
// import herudi.vjs.web
//
// fn main() {
//   rt := vjs.new_runtime()
//   ctx := rt.new_context()
//
//   web.window_api(ctx)
// }
// ```
@[manualfree]
pub fn window_api(ctx &Context) {
	glob := ctx.js_global()
	glob.set('window', glob.dup_value())
	glob.set('self', glob.dup_value())
	glob.free()
}
