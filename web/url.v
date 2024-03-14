module web

import vjs { Context }

pub fn url_api(ctx &Context) {
	ctx.eval_file('${@VMODROOT}/web/js/url.js', vjs.type_module) or { panic(err) }
}
