# VJS

Experimental [V](https://vlang.io/) bindings to [QuickJS](https://bellard.org/quickjs/) javascript engine.

> Current Status: [WIP]

## Features

- Evaluate js.
- Evaluate file js.
- Set-Module support.
- Set-Globals support.
- Callback function support.
- JS Atom support.
- Top level-await support using `vjs.type_module`.

## Usage

```bash
git clone https://github.com/herudi/vjs

cd vjs

v run examples/fib.v
```

Explore [examples](https://github.com/herudi/vjs/tree/master/examples)

> Tested in linux_x86_64.

## Simple Code

```v
rt := vjs.new_runtime()
ctx := rt.new_context()

code := '1 + 2'
value := ctx.eval(code) or { panic(err) }

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

## Add Global

```v
rt := vjs.new_runtime()
ctx := rt.new_context()

glob := ctx.js_global()
glob.set('foo', 'bar')

value := ctx.eval('foo') or { panic(err) }

println(value)
// bar
```

## Function

```v
rt := vjs.new_runtime()
ctx := rt.new_context()

glob := ctx.js_global()
glob.set('sum', ctx.js_function(fn [ctx] (args []vjs.Value) vjs.Value {
  if args.len < 2 {
    return ctx.js_undefined()
  }
  return ctx.js_int(args[0].to_int() + args[1].to_int())
}))

value := ctx.eval('sum(1, 2)') or { panic(err) }

println(value)
// 3
```

## Callback Function

```v
rt := vjs.new_runtime()
ctx := rt.new_context()

glob := ctx.js_global()
glob.set('callback', ctx.js_function(fn [ctx] (args []vjs.Value) vjs.Value {
  if args.len == 0 {
    unsafe { goto undefined }
  }
  func := args[0]
  if !func.is_function() {
    unsafe { goto undefined }
  }
  foo := func.callback('foo') or { panic(err) }
  println(foo)
  return foo
  undefined: 
    return ctx.js_undefined()
}))

value := ctx.eval('callback((foo) => foo)') or { panic(err) }
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
