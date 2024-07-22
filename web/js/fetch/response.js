import { vjs_inspect } from "../util.js";
import { Body } from "./body.js";
import { Headers } from "./headers.js";

const { isRedirect } = globalThis.__bootstrap.util;
const C_TYPE = "Content-Type";
const JSON_TYPE = "application/json";
export class Response extends Body {
  #input;
  #opts;
  constructor(input, opts = {}) {
    super(input);
    this.#input = input;
    this.#opts = opts;
  }

  get ok() {
    return this.status >= 200 && this.status < 300;
  }
  get headers() {
    return new Headers(this.#opts.headers ?? {});
  }
  get url() {
    return this.#opts.url ?? "";
  }
  get status() {
    return this.#opts.status ?? 200;
  }
  get statusText() {
    return this.#opts.statusText ?? "OK";
  }
  get redirected() {
    return false;
  }
  get type() {
    return this.#opts.type ?? "default";
  }
  clone() {
    return new Response(this.#input, this.#opts);
  }
  static error() {
    return new Response(null, { status: 0, statusText: "", type: "error" });
  }
  static redirect(url, status = 302) {
    if (!isRedirect(status)) {
      throw new RangeError(
        'Failed to execute "redirect" on "response": Invalid status code',
      );
    }
    return new Response(null, {
      headers: {
        location: new URL(url).href,
      },
      status,
    });
  }
  static json(data, init = {}) {
    if (data === void 0) {
      throw new TypeError("data is not JSON serializable");
    }
    if (init.headers) {
      const headers = new Headers(init.headers);
      if (!headers.has(C_TYPE)) headers.set(C_TYPE, JSON_TYPE);
      init.headers = headers;
    } else {
      init.headers = { [C_TYPE]: JSON_TYPE };
    }
    return new Response(JSON.stringify(data), init);
  }
  [vjs_inspect](format) {
    return "Response " + format({
      bodyUsed: this.bodyUsed,
      status: this.status,
      statusText: this.statusText,
      url: this.url,
      ok: this.ok,
      headers: this.headers,
    });
  }
}
