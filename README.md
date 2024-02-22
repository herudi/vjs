# VJS

Experimental [V](https://vlang.io/) bindings to [QuickJS](https://bellard.org/quickjs/).

> Current Status: [WIP]

## Usage
```bash
git clone https://github.com/herudi/vjs

cd vjs

v -cc clang run examples/fib.v
```
See [examples](https://github.com/herudi/vjs/tree/master/examples)

> Tested in linux_x86_64.

## Code
```v
rt := vjs.new_runtime()
defer { rt.free() }

ctx := rt.new_context()
defer { ctx.free() }

code := '2 + 1'

value := ctx.eval(code) or { panic(err) }

println(value)
// 3
```

### It's Fun Project. PRs Wellcome :)