module web

import vjs { Context }

// Add URL API to globals (`URL`, `URLSearchParams`).
// Example:
// ```v
// import herudi.vjs
// import herudi.vjs.web
//
// fn main() {
//   rt := vjs.new_runtime()
//   ctx := rt.new_context()
//
//   web.url_api(ctx)
// }
// ```
pub fn url_api(ctx &Context) {
	ctx.eval_file('${@VMODROOT}/web/js/url.js', vjs.type_module) or { panic(err) }
}
