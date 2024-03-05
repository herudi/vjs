module vjs

#flag -I @VMODROOT/lib
#flag -lm
$if linux {
	#flag @VMODROOT/lib/qjs_linux_x64.a
} $else $if macos {
	#flag @VMODROOT/lib/qjs_macos_x64.a
} $else $if windows {
	#flag @VMODROOT/lib/qjs_win_x64.a
}
#include "quickjs-libc.h"
#include "quickjs.h"
