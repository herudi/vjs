module web

import vjs { Context, Value }

@[manualfree]
pub fn encoding_api(ctx &Context) {
	obj := ctx.js_object()
	obj.set('str_to_ab', ctx.js_function(fn [ctx] (args []Value) Value {
		return ctx.js_array_buffer(args[0].str().bytes())
	}))
	obj.set('ab_to_str', ctx.js_function(fn [ctx] (args []Value) Value {
		bytes := args[0].to_bytes()
		return ctx.js_string(bytes.bytestr())
	}))
	glob := ctx.js_global()
	glob.set('__encoding', obj)
	ctx.eval_file('${@VMODROOT}/web/js/encoding.js', vjs.type_module) or { panic(err) }
	glob.free()
}
