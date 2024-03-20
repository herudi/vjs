module web

import vjs { Context, Value }

@[manualfree]
fn text_encode(this Value, args []Value) Value {
	uint_cls := this.ctx.js_global('Uint8Array')
	if args.len == 0 {
		return uint_cls.new()
	}
	if args[0].is_undefined() {
		return uint_cls.new()
	}
	arr_buf := this.ctx.js_array_buffer(args[0].str().bytes())
	uint := uint_cls.new(arr_buf)
	arr_buf.free()
	return uint
}

@[manualfree]
fn text_encode_into(this Value, args []Value) Value {
	if args.len != 2 {
		err := this.ctx.js_type_error(message: 'expected args 2 but got ${args.len}')
		return this.ctx.js_throw(err)
	}
	buf := text_encode(this, args)
	obj := this.ctx.js_object()
	text_len := args[0].len()
	buf_len := buf.len()
	arr_len := args[1].len()
	obj.set('read', text_len)
	obj.set('written', buf_len)
	if buf_len > arr_len {
		read_val := arr_len / buf_len * obj.get('read').to_int()
		obj.set('read', read_val)
		obj.set('written', arr_len)
	}
	args[1].call('set', buf, 0)
	buf.free()
	return obj
}

@[manualfree]
fn text_decode(this Value, args []Value) Value {
	if args.len == 0 {
		return this.ctx.js_string('')
	}
	mut buf := args[0]
	if buf.is_undefined() {
		return this.ctx.js_string('')
	}
	if buf.instanceof('ArrayBuffer') {
		return this.ctx.js_string(buf.to_bytes().bytestr())
	}
	if is_typed_array(this, args) {
		buf = buf.get('buffer')
		ret := this.ctx.js_string(buf.to_bytes().bytestr())
		buf.free()
		return ret
	}
	err := this.ctx.js_type_error(message: 'args[0] not TypedArray')
	return this.ctx.js_throw(err)
}

fn encoding_boot(ctx &Context, boot Value) {
	boot.set('text_encode', ctx.js_function_this(text_encode))
	boot.set('text_decode', ctx.js_function_this(text_decode))
	boot.set('text_encode_into', ctx.js_function_this(text_encode_into))
}

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
	glob, boot := get_bootstrap(ctx)
	encoding_boot(ctx, boot)
	ctx.eval_file('${@VMODROOT}/web/js/encoding.js', vjs.type_module) or { panic(err) }
	glob.free()
}
