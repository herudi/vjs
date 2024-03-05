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
	$if amd64 {
		#flag @VMODROOT/lib/qjs_linux_amd64.a
	}
	// else for arm
} $else $if macos {
	$if amd64 {
		#flag @VMODROOT/lib/qjs_macos_amd64.a
	}
} $else $if windows {
	#flag @VMODROOT/lib/qjs_win_amd64.a
}

#include "quickjs-libc.h"
#include "quickjs.h"
