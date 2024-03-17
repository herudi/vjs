module vjs

@[typedef]
struct C.JSAtom {}

@[typedef]
struct C.JSPropertyEnum {
	is_enumerable bool
	atom          C.JSAtom
}

// Atom structure based on `JSAtom` in qjs
// and implemented into `ref`.
pub struct Atom {
	ref C.JSAtom
	ctx Context
}

// PropertyEnum structure based on `JSPropertyEnum` in qjs.
pub struct PropertyEnum {
pub:
	atom          Atom
	is_enumerable bool
}

pub type AtomValue = int | string

fn C.JS_AtomToCString(&C.JSContext, C.JSAtom) &char
fn C.JS_AtomToValue(&C.JSContext, C.JSAtom) C.JSValue
fn C.JS_NewAtom(&C.JSContext, &char) C.JSAtom
fn C.JS_FreeAtom(&C.JSContext, C.JSAtom)
fn C.JS_NewAtomUInt32(&C.JSContext, u32) C.JSAtom
fn C.JS_GetOwnPropertyNames(&C.JSContext, &&C.JSPropertyEnum, &u32, JSValueConst, int) int

// Create new Atom support `int` | `string`.
// Example:
// ```v
// atom := ctx.new_atom('my_atom')
// ```
@[manualfree]
pub fn (ctx &Context) new_atom(val AtomValue) Atom {
	if val is string {
		ptr := val.str
		atom := Atom{
			ctx: ctx
			ref: C.JS_NewAtom(ctx.ref, ptr)
		}
		unsafe {
			free(ptr)
		}
		return atom
	}
	return Atom{
		ctx: ctx
		ref: C.JS_NewAtomUInt32(ctx.ref, u32(val as int))
	}
}

// Convert Atom to string.
@[manualfree]
pub fn (a Atom) to_string() string {
	ptr := C.JS_AtomToCString(a.ctx.ref, a.ref)
	ret := v_str(ptr)
	C.JS_FreeCString(a.ctx.ref, ptr)
	return ret
}

// Convert Atom to string.
pub fn (a Atom) str() string {
	return a.to_string()
}

// Convert Atom to Value.
// Example:
// ```v
// val := atom.to_value()
// println(val)
// ```
pub fn (a Atom) to_value() Value {
	return a.ctx.c_val(C.JS_AtomToValue(a.ctx.ref, a.ref))
}

// arrays property_names `[]PropertyEnum`.
// Example:
// ```v
// props := val.property_names() or { panic(err) }
// println(props)
//
// for prop in props {
//   println(prop.atom)
// 	 println(prop.is_enumerable)
// }
// ```
@[manualfree]
pub fn (v Value) property_names() ![]PropertyEnum {
	mut ref := &C.JSPropertyEnum{}
	mut size := u32(0)
	flag := 1 << 0 | 1 << 1 | 1 << 2
	res := C.JS_GetOwnPropertyNames(v.ctx.ref, &ref, &size, v.ref, flag)
	if res < 0 {
		return v.ctx.js_error(message: 'value does not contain properties').to_error()
	}
	defer {
		C.js_free(v.ctx.ref, ref)
	}
	len := int(size)
	mut props := []PropertyEnum{cap: len}
	for i in 0 .. len {
		prop := unsafe { ref[i] }
		atom := Atom{
			ctx: v.ctx
			ref: prop.atom
		}
		props << PropertyEnum{
			atom: atom
			is_enumerable: prop.is_enumerable
		}
	}
	return props
}

// Free Atom
pub fn (a &Atom) free() {
	C.JS_FreeAtom(a.ctx.ref, a.ref)
}
