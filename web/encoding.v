module web

import vjs { Context, Value }

// Add encoding API to globals (`TextEncoder`, `TextDecoder`).
// Example:
// ```v
// import herudi.vjs
// import herudi.vjs.web
//
// fn main() {
//   rt := vjs.new_runtime()
//   ctx := rt.new_context()
//
//   web.encoding_api(ctx)
// }
// ```
@[manualfree]
pub fn encoding_api(ctx &Context) {
	obj := ctx.js_object()
	obj.set('str_to_ab', ctx.js_function(fn [ctx] (args []Value) Value {
		return ctx.js_array_buffer(args[0].str().bytes())
	}))
	obj.set('ab_to_str', ctx.js_function(fn [ctx] (args []Value) Value {
		return ctx.js_string(args[0].to_bytes().bytestr())
	}))
	glob := ctx.js_global()
	glob.set('__encoding', obj)
	ctx.eval_file('${@VMODROOT}/web/js/encoding.js', vjs.type_module) or { panic(err) }
	glob.delete('__encoding')
	glob.free()
}
