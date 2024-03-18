module web

import vjs { Context }

// Add Blob API to globals.
// Example:
// ```v
// import herudi.vjs
// import herudi.vjs.web
//
// fn main() {
//   rt := vjs.new_runtime()
//   ctx := rt.new_context()
//
//   web.blob_api(ctx)
// }
// ```
pub fn blob_api(ctx &Context) {
	ctx.eval_file('${@VMODROOT}/web/js/blob.js', vjs.type_module) or { panic(err) }
}
