import vjs { Value }

fn test_atom() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()
	atom_str := ctx.new_atom('foo')
	atom_i64 := ctx.new_atom(i64(20))

	assert atom_str.str() == 'foo'
	assert atom_i64.to_value().to_i64() == 20

	obj := ctx.js_object()
	obj.set('foo', 'foo')
	obj.set('bar', 'bar')
	props := obj.property_names() or { panic(err) }
	for prop in props {
		assert prop.is_enumerable == true
	}
	assert props[0].atom.str() == 'foo'
	assert props[1].atom.str() == 'bar'
	obj.free()
	atom_i64.free()
	atom_str.free()
	ctx.free()
	rt.free()
}

fn test_callback() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()
	glob := ctx.js_global()
	glob.set('my_fn', ctx.js_function(fn [ctx] (args []Value) Value {
		if args.len == 0 {
			return ctx.js_undefined()
		}
		return ctx.js_string(args.map(fn (val Value) string {
			if val.is_function() {
				val_from_fn := val.callback('baz') or { panic(err) }
				return val_from_fn.str()
			}
			return val.str()
		}).join(','))
	}))

	code := '
		my_fn("foo", "bar", (param) => {
			return param;
		})
	'

	value := ctx.eval(code) or { panic(err) }
	ctx.end()

	assert value.is_string() == true
	assert value.to_string() == 'foo,bar,baz'

	// free
	value.free()
	glob.free()
	ctx.free()
	rt.free()
}

fn test_module() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()

	mut mod := ctx.js_module('my-module')
	mod.export('foo', ctx.js_function(fn [ctx] (args []Value) Value {
		assert args.len == 1
		assert args[0].str() == 'foo'
		return ctx.js_undefined()
	}))
	mod.export_default(mod.to_object())
	mod.create()

	code := '
		import mod, { foo } from "my-module";

		foo("foo");

		mod.foo("foo");
	'

	ctx.eval(code, vjs.type_module) or { panic(err) }
	ctx.end()

	ctx.free()
	rt.free()
}
