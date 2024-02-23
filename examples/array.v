import vjs

fn main() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()

	array := ctx.js_array()

	array.call('push', 'foo')
	array.call('push', 'bar')
	array.call('unshift', 1)
	array.call('push', 2)

	assert array.len() == 4

	global := ctx.js_global()
	global.set('my_arr', array)

	value := ctx.eval('my_arr') or { panic(err) }

	assert value.json_stringify() == '[1,"foo","bar",2]'
	println('result => ${value}')

	// free
	value.free()
	global.free()
	array.free()
	ctx.free()
	rt.free()
}
