module vjs

type JSModuleInitFunc = fn (&C.JSContext, &C.JSModuleDef) int

fn C.JS_NewCModule(&C.JSContext, &char, &JSModuleInitFunc) &C.JSModuleDef
fn C.JS_SetModuleExport(&C.JSContext, &C.JSModuleDef, &char, C.JSValue) int
fn C.JS_AddModuleExport(&C.JSContext, &C.JSModuleDef, &char) int

// Module structure.
pub struct Module {
	ctx  Context
	name string
mut:
	exports_str []string
	exports     []&char
	values      []Value
}

// Initial `js_module`.
// Example:
// ```v
// mod := ctx.js_module('my-module')
// ```
pub fn (ctx &Context) js_module(name string) Module {
	return Module{
		ctx: ctx
		name: name
	}
}

// Export module.
// Example:
// ```v
// mod.export('foo', 'bar')
// ```
@[manualfree]
pub fn (mut m Module) export(name string, any AnyValue) {
	ptr := name.str
	m.exports_str << name
	m.exports << ptr
	m.values << m.ctx.any_to_val(any)
	unsafe {
		free(ptr)
	}
}

// Same as Export.
pub fn (mut m Module) set(name string, any AnyValue) {
	m.export(name, any)
}

// Get value from export/set.
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

// Convert module to JS object.
pub fn (mut m Module) to_object() Value {
	obj := m.ctx.js_object()
	len := m.exports_str.len
	for i in 0 .. len {
		obj.set(m.exports_str[i], m.values[i])
	}
	return obj
}

// Export default.
// Example:
// ```v
// mod.export_default(mod.to_object())
// ```
pub fn (mut m Module) export_default(any AnyValue) {
	m.export('default', any)
}

// Create module.
// Example:
// ```v
// mod := ctx.js_module('my-module')
// mod.export('foo', 'bar')
// mod.export_default(mod.to_object())
// mod.create()
// ```
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
