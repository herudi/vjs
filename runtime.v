module vjs

@[typedef]
struct C.JSRuntime {}

pub struct Runtime {
	ref &C.JSRuntime
}

@[params]
pub struct JSError {
	Error
pub mut:
	name    string = 'Error'
	stack   string
	message string
}

pub fn (err &JSError) msg() string {
	return '${err.message}\n${err.stack}'
}

fn C.JS_NewRuntime() &C.JSRuntime
fn C.JS_SetCanBlock(&C.JSRuntime, int)
fn C.JS_FreeRuntime(&C.JSRuntime)
fn C.JS_RunGC(&C.JSRuntime)
fn C.JS_SetMaxStackSize(&C.JSRuntime, usize)
fn C.JS_SetGCThreshold(&C.JSRuntime, usize)
fn C.JS_SetMemoryLimit(&C.JSRuntime, usize)
fn C.JS_IsJobPending(&C.JSRuntime) bool

pub fn new_runtime() Runtime {
	rt := Runtime{C.JS_NewRuntime()}
	C.JS_SetCanBlock(rt.ref, 1)
	return rt
}

pub fn (rt Runtime) is_job_pending() bool {
	return C.JS_IsJobPending(rt.ref)
}

pub fn (rt Runtime) set_memory_limit(limit u32) {
	C.JS_SetMemoryLimit(rt.ref, usize(limit))
}

pub fn (rt Runtime) set_max_stack_size(stack_size u32) {
	C.JS_SetMaxStackSize(rt.ref, usize(stack_size))
}

pub fn (rt Runtime) set_gc_threshold(th i64) {
	C.JS_SetGCThreshold(rt.ref, usize(th))
}

pub fn (rt Runtime) run_gc() {
	C.JS_RunGC(rt.ref)
}

pub fn (rt &Runtime) free() {
	C.JS_FreeRuntime(rt.ref)
}
