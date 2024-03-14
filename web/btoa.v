module web

import vjs { Context, Value }
import encoding.base64

pub fn btoa(ctx &Context) Value {
	return ctx.js_function(fn [ctx] (args []Value) Value {
		if args.len == 0 {
			return ctx.js_throw('args[0] is required')
		}
		ret := base64.encode_str(args[0].str())
		return ctx.js_string(ret)
	})
}

@[manualfree]
pub fn btoa_api(ctx &Context) {
	glob := ctx.js_global()
	glob.set('btoa', btoa(ctx))
	glob.free()
}
