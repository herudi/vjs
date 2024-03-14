module web

import vjs { Context }

@[manualfree]
pub fn inject(ctx &Context) {
	atob_api(ctx)
	btoa_api(ctx)
	console_api(ctx)
	encoding_api(ctx)
	timer_api(ctx)
	url_api(ctx)
}
