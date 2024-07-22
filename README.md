# VJS

[V](https://vlang.io/) bindings to [QuickJS](https://bellard.org/quickjs/)
javascript engine. Run JS in V.

## Features

- Evaluate js (code, file, module, etc).
- Multi evaluate support.
- Callback function support.
- Set-Globals support.
- Set-Module support.
- Call V from JS.
- Call JS from V.
- Top-Level `await` support. using `vjs.type_module`.

## Install

```bash
v install herudi.vjs
```

## Basic Usage

Create file `main.v` and copy-paste this code.

```v
import herudi.vjs

fn main() {
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
}
```

## Run

```bash
v run main.v
```

Explore [examples](https://github.com/herudi/vjs/tree/master/examples)

> Currently support linux/mac/win (x64).

> in windows, requires `-cc gcc`.

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

Inject Web API to vjs.

```v
import herudi.vjs
import herudi.vjs.web

fn main() {
  rt := vjs.new_runtime()
  ctx := rt.new_context()

  // inject all
  web.inject(ctx)

  // or inject one by one
  // web.console_api(ctx)
  // web.encoding_api(ctx)
  // more..

  ...
}
```
### List Web Platform APIs
- [x] [Console](https://developer.mozilla.org/en-US/docs/Web/API/console)
- [x] [setTimeout](https://developer.mozilla.org/en-US/docs/Web/API/setTimeout),
      [clearTimeout](https://developer.mozilla.org/en-US/docs/Web/API/clearTimeout)
- [x] [setInterval](https://developer.mozilla.org/en-US/docs/Web/API/setInterval),
      [clearInterval](https://developer.mozilla.org/en-US/docs/Web/API/clearInterval)
- [x] [btoa](https://developer.mozilla.org/en-US/docs/Web/API/btoa),
      [atob](https://developer.mozilla.org/en-US/docs/Web/API/atob)
- [x] [URL](https://developer.mozilla.org/en-US/docs/Web/API/URL)
- [x] [URLSearchParams](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams)
- [x] [URLPattern](https://developer.mozilla.org/en-US/docs/Web/API/URLPattern)
- [x] [Encoding API](https://developer.mozilla.org/en-US/docs/Web/API/Encoding_API)
  - [x] [TextEncoder](https://developer.mozilla.org/en-US/docs/Web/API/TextEncoder)
  - [x] [TextDecoder](https://developer.mozilla.org/en-US/docs/Web/API/TextDecoder)
  - [x] [TextEncoderStream](https://developer.mozilla.org/en-US/docs/Web/API/TextEncoderStream)
  - [x] [TextDecoderStream](https://developer.mozilla.org/en-US/docs/Web/API/TextDecoderStream)
- [x] [Crypto API](https://developer.mozilla.org/en-US/docs/Web/API/Crypto)
  - [x] [randomUUID](https://developer.mozilla.org/en-US/docs/Web/API/Crypto/randomUUID)
  - [x] [getRandomValues](https://developer.mozilla.org/en-US/docs/Web/API/Crypto/getRandomValues)
- [x] [SubtleCrypto](https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto)
  - [x] [digest](https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto/digest)
  - [ ] encrypt
  - [ ] decrypt
  - [ ] sign
  - [ ] verify
- [x] [Streams API](https://developer.mozilla.org/en-US/docs/Web/API/Streams_API)
- [x] [FormData](https://developer.mozilla.org/en-US/docs/Web/API/FormData)
- [x] [Blob](https://developer.mozilla.org/en-US/docs/Web/API/Blob)
- [x] [File](https://developer.mozilla.org/en-US/docs/Web/API/File)
- [x] [Performance](https://developer.mozilla.org/en-US/docs/Web/API/Performance)
- [x] [Navigator](https://developer.mozilla.org/en-US/docs/Web/API/Navigator)
- [x] Fetch API
  - [x] Headers
  - [x] Request
  - [x] Response
- <i>More...</i>

### It's Fun Project. PRs Wellcome :)
