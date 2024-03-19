import { vjs_inspect } from "./util.js";

import { URLPattern as URLPatternPoly } from "./polyfill/url_pattern.js";

class URLPattern extends URLPatternPoly {
  [vjs_inspect]() {
    return {
      protocol: this.protocol,
      username: this.username,
      password: this.password,
      hostname: this.hostname,
      port: this.port,
      pathname: this.pathname,
      search: this.search,
      hash: this.hash,
    };
  }
}

globalThis.URLPattern = URLPattern;
