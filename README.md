# VJS

Experimental [V](https://vlang.io/) bindings to [QuickJS](https://bellard.org/quickjs/).

> Current Status: [WIP]

## Usage
```bash
git clone https://github.com/herudi/vjs

cd vjs

v -cc clang run main.v
```
> Tested in linux_x86_64.

## Example Code
```v
import vjs

fn main() {
	rt := vjs.new_runtime()
	defer { rt.free() }

	ctx := rt.new_context()
	defer { ctx.free() }

	code := '(() => {
		const fib = (n) => {
			return n < 1 ? 0
        : n <= 2 ? 1
        : fib(n - 1) + fib(n - 2)
		}
		return 2 * 1 + fib(10)
	})()'

	value := ctx.eval(code) or { panic(err) }
	defer { value.free() }

	println(value)
}
```

### It's Fun Project. PRs Wellcome :)