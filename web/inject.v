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
	console_api(ctx)
	performance_api(ctx)
	timer_api(ctx)
	atob_api(ctx)
	btoa_api(ctx)
	stream_api(ctx)
	encoding_api(ctx)
	url_api(ctx)
	crypto_api(ctx)
	navigator_api(ctx)
	blob_api(ctx)
	formdata_api(ctx)
}
