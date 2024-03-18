module web

import vjs { Context }

// Add FormData API to globals.
// Example:
// ```v
// import herudi.vjs
// import herudi.vjs.web
//
// fn main() {
//   rt := vjs.new_runtime()
//   ctx := rt.new_context()
//
//   web.formdata_api(ctx)
// }
// ```
pub fn formdata_api(ctx &Context) {
	ctx.eval_file('${@VMODROOT}/web/js/form_data.js', vjs.type_module) or { panic(err) }
}
