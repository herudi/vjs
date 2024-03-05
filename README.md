# VJS

Experimental [V](https://vlang.io/) bindings to [QuickJS](https://bellard.org/quickjs/) javascript engine.

> Current Status: [WIP]

## Features

- Evaluate js (code, file, module, etc).
- Multi evaluate support.
- Callback function support.
- Set-Globals support.
- Set-Module support.
- Top level-await support. using `vjs.type_module`.

## Usage

```bash
git clone https://github.com/herudi/vjs

cd vjs

v run examples/fib.v

// or windows
v -cc gcc run examples/fib.v
```

Explore [examples](https://github.com/herudi/vjs/tree/master/examples)

> Tested in linux/mac/win (x64).

## Simple Code

```v
rt := vjs.new_runtime()
ctx := rt.new_context()

value := ctx.eval('1 + 2') or { panic(err) }
ctx.end()

assert value.is_number() == true
assert value.is_string() == false
assert value.to_int() == 3

println(value)
// 3

// free
value.free()
ctx.free()
rt.free()
```
## Multi Evaluate

```v
ctx.eval('const sum = (a, b) => a + b') or { panic(err) }
ctx.eval('const mul = (a, b) => a * b') or { panic(err) }

sum := ctx.eval('sum(${1}, ${2})') or { panic(err) }
mul := ctx.eval('mul(${1}, ${2})') or { panic(err) }

ctx.end()

println(sum)
// 3

println(mul)
// 2
```

## Add Global

```v
glob := ctx.js_global()
glob.set('foo', 'bar')

value := ctx.eval('foo') or { panic(err) }
ctx.end()

println(value)
// bar
```

## Add Module

```v
mut mod := ctx.js_module('my-module')
mod.export('foo', 'foo')
mod.export('bar', 'bar')
mod.export_default(mod.to_object())
mod.create()

code := '
  import mod, { foo, bar } from "my-module";

  console.log(foo, bar);

  console.log(mod);
'

ctx.eval(code, vjs.type_module) or { panic(err) }
ctx.end()
```

## Web Platform APIs

- [x] [Console](https://developer.mozilla.org/en-US/docs/Web/API/console)
- [x] [setTimeout](https://developer.mozilla.org/en-US/docs/Web/API/setTimeout),
      [clearTimeout](https://developer.mozilla.org/en-US/docs/Web/API/clearTimeout)
- [x] [setInterval](https://developer.mozilla.org/en-US/docs/Web/API/setInterval),
      [clearInterval](https://developer.mozilla.org/en-US/docs/Web/API/clearInterval)
- [x] [btoa](https://developer.mozilla.org/en-US/docs/Web/API/btoa),
      [atob](https://developer.mozilla.org/en-US/docs/Web/API/atob)
- <i>More...</i>

### It's Fun Project. PRs Wellcome :)
