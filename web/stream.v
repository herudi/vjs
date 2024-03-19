module web

import vjs { Context }

// Add Stream API to globals (`ReadableStream`, `TransformStream`, `WritableStream`).
// Example:
// ```v
// import herudi.vjs
// import herudi.vjs.web
//
// fn main() {
//   rt := vjs.new_runtime()
//   ctx := rt.new_context()
//
//   web.stream_api(ctx)
// }
// ```
pub fn stream_api(ctx &Context) {
	ctx.eval_file('${@VMODROOT}/web/js/stream.js', vjs.type_module) or { panic(err) }
}
