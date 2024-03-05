module vjs

#flag -lm
#flag -I @VMODROOT/lib
$if tinyc {
	#flag @VMODROOT/lib/tcc/builtin.c
	#flag @VMODROOT/lib/tcc/umodti3.c
	#flag @VMODROOT/lib/tcc/divti3.c
	#flag @VMODROOT/lib/tcc/udivti3.c
	#flag @VMODROOT/lib/tcc/udivmodti4.c
}
$if linux {
	#flag @VMODROOT/lib/qjs_linux_x64.a
} $else $if macos {
	#flag @VMODROOT/lib/qjs_macos_x64.a
} $else $if windows {
	#flag @VMODROOT/lib/qjs_win_x64.a
}

#include "quickjs-libc.h"
#include "quickjs.h"
