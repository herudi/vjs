module vjs

#flag -I @VMODROOT/libs/include

$if x64 {
	$if linux {
		#flag @VMODROOT/libs/qjs_linux_x64.a
	} $else $if macos {
		#flag @VMODROOT/libs/qjs_macos_x64.a
	} $else $if windows {
		#flag @VMODROOT/libs/qjs_win_x64.a
	}
}

#flag -lpthread -lm
#include "quickjs-libc.h"
#include "quickjs.h"
