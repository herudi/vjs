import vjs

fn main() {
	rt := vjs.new_runtime()
	ctx := rt.new_context()

	code := '(() => {
		const fib = (n) => {
			return n < 1 ? 0
        : n <= 2 ? 1
        : fib(n - 1) + fib(n - 2)
		}
		return 2 * 1 + fib(10)
	})()'
	value := ctx.eval(code) or { panic(err) }
	ctx.end()

	println('Fib => ${value}')

	// free
	value.free()
	ctx.free()
	rt.free()
}
