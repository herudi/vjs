import vjs { Promise, Value }

fn test_promise() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()

	res := ctx.new_promise(fn (p Promise) Value {
		return p.resolve('foo')
	}).await()
	assert res.str() == 'foo'

	res2 := ctx.js_promise().resolve('bar').await()
	assert res2.str() == 'bar'

	ctx.free()
	rt.free()
}
