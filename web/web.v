module web

import vjs { Context }

fn get_bootstrap(ctx &Context) (vjs.Value, vjs.Value) {
	glob := ctx.js_global()
	if glob.get('__bootstrap').is_undefined() {
		glob.set('__bootstrap', ctx.js_object())
	}
	return glob, glob.get('__bootstrap')
}

// delete core `__bootstrap` from global
pub fn delete_bootstrap(ctx &Context) bool {
	glob := ctx.js_global()
	defer {
		glob.free()
	}
	if glob.get('__bootstrap').is_undefined() {
		return false
	}
	glob.delete('__bootstrap')
	return true
}

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
	glob, boot := get_bootstrap(ctx)
	util_boot(ctx, boot)
	console_boot(ctx, boot)
	navigator_boot(ctx, boot)
	crypto_boot(ctx, boot)
	encoding_boot(ctx, boot)
	performance_boot(ctx, boot)
	ctx.eval_file('${@VMODROOT}/web/js/inject.js', vjs.type_module) or { panic(err) }
	glob.delete('__bootstrap')
	glob.free()
}
