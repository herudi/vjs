module web

import vjs { Context, Value }
import rand
import crypto.sha1
import crypto.sha256
import crypto.sha512

// Add Crypto API to globals.
// Example:
// ```v
// import herudi.vjs
// import herudi.vjs.web
//
// fn main() {
//   rt := vjs.new_runtime()
//   ctx := rt.new_context()
//
//   web.crypto_api(ctx)
// }
// ```
@[manualfree]
pub fn crypto_api(ctx &Context) {
	obj := ctx.js_object()
	obj.set('rand_uuid', ctx.js_function(fn [ctx] (args []Value) Value {
		return ctx.js_string(rand.uuid_v4())
	}))
	obj.set('rand_bytes', ctx.js_function(fn [ctx] (args []Value) Value {
		bytes := rand.bytes(args[0].to_int()) or { panic(err) }
		return ctx.js_array_buffer(bytes)
	}))

	// digest impl
	obj.set('digest_sha1', ctx.js_function(fn [ctx] (args []Value) Value {
		sum := sha1.sum(args[0].to_bytes())
		return ctx.js_array_buffer(sum)
	}))
	obj.set('digest_sha256', ctx.js_function(fn [ctx] (args []Value) Value {
		sum := sha256.sum256(args[0].to_bytes())
		return ctx.js_array_buffer(sum)
	}))
	obj.set('digest_sha384', ctx.js_function(fn [ctx] (args []Value) Value {
		sum := sha512.sum384(args[0].to_bytes())
		return ctx.js_array_buffer(sum)
	}))
	obj.set('digest_sha512', ctx.js_function(fn [ctx] (args []Value) Value {
		sum := sha512.sum512(args[0].to_bytes())
		return ctx.js_array_buffer(sum)
	}))
	glob := ctx.js_global()
	glob.set('__crypto', obj)
	ctx.eval_file('${@VMODROOT}/web/js/crypto.js', vjs.type_module) or { panic(err) }
	glob.delete('__crypto')
	glob.free()
}
