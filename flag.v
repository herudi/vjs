module vjs

#flag -I @VMODROOT/libs/include
#flag -lm -lpthread

$if tinyc {
	// misc for tcc
	#flag @VMODROOT/libs/misc/divti3.c
	#flag @VMODROOT/libs/misc/udivti3.c
	#flag @VMODROOT/libs/misc/udivmodti4.c
}
$if x64 {
	$if linux {
		#flag @VMODROOT/libs/qjs_linux_x64.a
	} $else $if macos {
		#flag @VMODROOT/libs/qjs_macos_x64.a
	} $else $if windows {
		#flag @VMODROOT/libs/qjs_win_x64.a
	}
}
#include "quickjs-libc.h"
#include "quickjs.h"
