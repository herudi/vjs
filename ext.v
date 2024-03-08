module vjs

import encoding.base64

fn btoa_atob(ctx &Context, name string) JSFunction {
	return fn [ctx, name] (args []Value) Value {
		if args.len == 0 {
			return ctx.js_throw('value is required')
		}
		val := if name == 'btoa' {
			base64.encode_str(args[0].str())
		} else {
			base64.decode_str(args[0].str())
		}
		return ctx.js_string(val)
	}
}

pub fn (ctx &Context) init_ext() {
	vjs_core := ctx.js_object()
	vjs_core.set('print', ctx.js_function(fn [ctx] (args []Value) Value {
		println(args.map(it.str()).join(' '))
		return ctx.js_undefined()
	}))
	vjs_core.set('str_to_ab', ctx.js_function(fn [ctx] (args []Value) Value {
		return ctx.js_array_buffer(args[0].str().bytes())
	}))
	vjs_core.set('ab_to_str', ctx.js_function(fn [ctx] (args []Value) Value {
		bytes := args[0].to_bytes()
		return ctx.js_string(bytes.bytestr())
	}))
	glob := ctx.js_global()
	glob.set('__vjs_global__', true)
	glob.set('__bootstrap', vjs_core)
	glob.set('btoa', ctx.js_function(btoa_atob(ctx, 'btoa')))
	glob.set('atob', ctx.js_function(btoa_atob(ctx, 'atob')))
	ctx.eval_file('${@VMODROOT}/ext/main.js', type_module) or { panic(err) }
	glob.free()
}
