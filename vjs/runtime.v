module vjs

#flag -lm
#flag -I @VMODROOT/lib
#flag @VMODROOT/lib/libquickjs.a
#include "quickjs.h"

@[typedef]
struct C.JSRuntime {}

pub struct Runtime {
	ref &C.JSRuntime
}

@[params]
pub struct JSError {
	Error
	message string
}

fn (err JSError) msg() string {
	return err.message
}

fn C.JS_NewRuntime() &C.JSRuntime
fn C.JS_SetCanBlock(&C.JSRuntime, int)
fn C.JS_FreeRuntime(&C.JSRuntime)

pub fn new_runtime() Runtime {
	rt := Runtime{C.JS_NewRuntime()}
	C.JS_SetCanBlock(rt.ref, 1)
	return rt
}

@[manualfree]
pub fn (rt &Runtime) free() {
	C.JS_FreeRuntime(rt.ref)
}
