module vjs

fn u_free[T](ptr T) T {
	unsafe { free(ptr) }
	return ptr
}

fn v_str[T](val T) string {
	return unsafe { cstring_to_vstring(val) }
}
