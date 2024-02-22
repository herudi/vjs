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

## Simple Code
```v
rt := vjs.new_runtime()
defer { rt.free() }

ctx := rt.new_context()
defer { ctx.free() }

code := '1 + 2'

value := ctx.eval(code) or { panic(err) }
defer { value.free() }

assert value.is_number() == true
assert value.is_string() == false
assert value.int() == 3

println(value)
// 3
```

## Add Global
```v
rt := vjs.new_runtime()
defer { rt.free() }

ctx := rt.new_context()
defer { ctx.free() }

glob := ctx.js_global()
defer { glob.free() }

glob.set('foo', 'bar')

value := ctx.eval('foo') or { panic(err) }
defer { value.free() }

println(value)
// bar
```

## Callback
```v
rt := vjs.new_runtime()
defer { rt.free() }

ctx := rt.new_context()
defer { ctx.free() }

glob := ctx.js_global()
defer { glob.free() }

glob.set('my_fn', ctx.js_callback(fn (ctx &vjs.Context, args []vjs.Value) vjs.Value {
  if args.len == 0 {
    return ctx.js_undefined()
  }
  return ctx.js_string(args.map(it.str()).join(','))
}))

value := ctx.eval('my_fn("foo", "bar")') or { panic(err) }
defer { value.free() }

println(value)
// foo,bar
```

### It's Fun Project. PRs Wellcome :)
