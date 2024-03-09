import vjs { Promise, Value }

fn test_promise() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()

	res := ctx.new_promise(fn (p Promise) Value {
		return p.resolve('foo')
	})
	val := res.await()!
	assert val.str() == 'foo'

	res2 := ctx.js_promise()
	val2 := res2.resolve('bar')
	val3 := val2.await()!
	assert val3.str() == 'bar'

	ctx.free()
	rt.free()
}
