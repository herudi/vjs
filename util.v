module vjs

fn v_str[T](val T) string {
	return unsafe { cstring_to_vstring(val) }
}
