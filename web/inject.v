module web

import vjs { Context }

// Inject All Web-API features.
// Example:
// ```v
// import herudi.vjs
// import herudi.vjs.web
//
// fn main() {
//   rt := vjs.new_runtime()
//   ctx := rt.new_context()
//
//   web.inject(ctx)
// }
// ```
pub fn inject(ctx &Context) {
	window_api(ctx)
	atob_api(ctx)
	btoa_api(ctx)
	console_api(ctx)
	encoding_api(ctx)
	timer_api(ctx)
	url_api(ctx)
	crypto_api(ctx)
}
