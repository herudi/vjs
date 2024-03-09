module vjs

#flag -I @VMODROOT/quickjs
#flag -lm

$if tinyc {
	#flag @VMODROOT/libs/tcc/builtin.c
	#flag @VMODROOT/libs/tcc/divti3.c
	#flag @VMODROOT/libs/tcc/udivti3.c
	#flag @VMODROOT/libs/tcc/umodti3.c
	#flag @VMODROOT/libs/tcc/udivmodti4.c
}
$if x64 {
	$if linux {
		#flag @VMODROOT/libs/qjs_linux_x64.a
	} $else $if macos {
		#flag @VMODROOT/libs/qjs_macos_x64.a
	} $else $if windows {
		#flag @VMODROOT/libs/qjs_win_x64.a
	} $else {
		#flag @VMODROOT/quickjs/libquickjs.a
	}
} $else {
	#flag @VMODROOT/quickjs/libquickjs.a
}
#include "quickjs-libc.h"
#include "quickjs.h"
