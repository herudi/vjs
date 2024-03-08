import vjs { Promise, Value }

fn test_promise() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()

	res := ctx.new_promise(fn (p Promise) Value {
		return p.resolve('foo')
	})

	val := res.await()!

	assert val.str() == 'foo'

	val.free()
	res.free()
	ctx.free()
	rt.free()
}
