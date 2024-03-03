module vjs

type JSModuleInitFunc = fn (&C.JSContext, &C.JSModuleDef) int

fn C.JS_NewCModule(&C.JSContext, &char, &JSModuleInitFunc) &C.JSModuleDef
fn C.JS_SetModuleExport(&C.JSContext, &C.JSModuleDef, &char, C.JSValue) int
fn C.JS_AddModuleExport(&C.JSContext, &C.JSModuleDef, &char) int

pub struct Module {
	ctx  Context
	name string
mut:
	exports_str []string
	exports     []&char
	values      []Value
}

pub fn (ctx &Context) js_module(name string) Module {
	return Module{
		ctx: ctx
		name: name
	}
}

pub fn (mut m Module) export(name string, any AnyValue) {
	ptr := name.str
	m.exports_str << name
	m.exports << ptr
	m.values << m.ctx.any_to_val(any)
	u_free(ptr)
}

pub fn (mut m Module) set(name string, any AnyValue) {
	m.export(name, any)
}

pub fn (mut m Module) get(name string) Value {
	mut val := m.ctx.js_undefined()
	len := m.exports_str.len
	for i in 0 .. len {
		str := m.exports_str[i]
		if str == name {
			val = m.values[i]
			break
		}
	}
	return val
}

pub fn (mut m Module) to_object() Value {
	obj := m.ctx.js_object()
	len := m.exports.len
	for i in 0 .. len {
		obj.set(v_str(m.exports[i]), m.values[i])
	}
	return obj
}

pub fn (mut m Module) export_default(any AnyValue) {
	ptr := 'default'.str
	m.exports << ptr
	m.values << m.ctx.any_to_val(any)
	u_free(ptr)
}

pub fn (mut m Module) create() &C.JSModuleDef {
	cb := fn [m] (ctx &C.JSContext, mod &C.JSModuleDef) int {
		len := m.exports.len
		for i in 0 .. len {
			export := m.exports[i]
			value := m.values[i]
			C.JS_SetModuleExport(ctx, mod, export, value.ref)
		}
		return len
	}
	ref := C.JS_NewCModule(m.ctx.ref, m.name.str, cb)
	for export in m.exports {
		C.JS_AddModuleExport(m.ctx.ref, ref, export)
	}
	return ref
}
