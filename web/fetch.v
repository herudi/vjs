module web

import vjs { Context, Value }
import net.http { Method, Response, parse_multipart_form }

fn fetch(this Value, args []Value) Value {
	mut error := this.ctx.js_undefined()
	promise := this.ctx.js_promise()
	url := args[0].str()
	opts := args[1]
	header := opts.get('headers')
	method := opts.get('method').str().to_lower()
	raw_body := opts.get('body')
	boundary := opts.get('boundary')
	mut hd := http.new_header()
	props := header.property_names() or { panic(err) }
	for data in props {
		key := data.atom.str()
		hd.set_custom(key, header.get(key).str()) or {
			error = this.ctx.js_error(message: err.msg())
			unsafe {
				goto reject
			}
			break
		}
	}
	mut body := raw_body.str()
	mut resp := Response{}
	if boundary.is_undefined() {
		resp = http.fetch(
			url: url
			method: Method.from(method) or { Method.get }
			header: hd
			data: body
		) or {
			error = this.ctx.js_error(message: err.msg())
			unsafe {
				goto reject
			}
			Response{}
		}
	} else {
		form, files := parse_multipart_form(body, '----formdata-' + boundary.str())
		resp = http.post_multipart_form(url, form: form, header: hd, files: files) or {
			error = this.ctx.js_error(message: err.msg())
			unsafe {
				goto reject
			}
			Response{}
		}
	}
	mut resp_header := resp.header
	obj_header := this.ctx.js_object()
	for key in resp_header.keys() {
		val := resp_header.custom_values(key)
		obj_header.set(key, val.join('; '))
	}
	obj := this.ctx.js_object()
	obj.set('body', resp.body)
	obj.set('status', resp.status_code)
	obj.set('status_message', resp.status_msg)
	obj.set('header', obj_header)
	resp_header.free()
	return promise.resolve(obj)
	reject:
	return promise.reject(error)
}

fn fetch_boot(ctx &Context, boot Value) {
	boot.set('core_fetch', ctx.js_function_this(fetch))
}

// Add Fetch API to globals.
// Example:
// ```v
// import herudi.vjs
// import herudi.vjs.web
//
// fn main() {
//   rt := vjs.new_runtime()
//   ctx := rt.new_context()
//
//   web.fetch_api(ctx)
// }
// ```
pub fn fetch_api(ctx &Context) {
	glob, boot := get_bootstrap(ctx)
	fetch_boot(ctx, boot)
	ctx.eval_file('${@VMODROOT}/web/js/fetch.js', vjs.type_module) or { panic(err) }
	glob.free()
}
