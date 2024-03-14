module web

import vjs { Context }

pub fn timer_api(ctx &Context) {
	ctx.eval_file('${@VMODROOT}/web/js/timer.js', vjs.type_module) or { panic(err) }
}
