import { vjs_inspect } from "../util.js";
import { Body } from "./body.js";
import { Headers } from "./headers.js";

export class Request extends Body {
  #input = "";
  #opts;
  constructor(input, opts = {}) {
    let _input;
    if (typeof input === "string") {
      _input = input;
    } else if (input instanceof URL) {
      _input = input.href;
    } else {
      opts.method = input.method ?? "GET";
      opts.body = input.body;
      opts.headers = input.headers;
      opts.keepalive = input.keepalive;
      _input = input.url;
    }
    super(opts.body);
    this.#input = _input;
    this.#opts = opts;
    if (
      (this.#opts.method === "GET" || this.#opts.method === "HEAD") &&
      this.#opts.body != null
    ) {
      throw new TypeError("Request with GET/HEAD method cannot have body.");
    }
  }
  clone() {
    return new Request(this, this.#opts);
  }
  get method() {
    return this.#opts.method ?? "GET";
  }
  get redirect() {
    return "follow";
  }
  get headers() {
    return new Headers(this.#opts.headers ?? {});
  }
  get keepalive() {
    return this.#opts.keepalive ?? true;
  }
  get url() {
    return this.#input ?? "";
  }
  [vjs_inspect](format) {
    return "Request " + format({
      bodyUsed: this.bodyUsed,
      method: this.method,
      url: this.url,
      headers: this.headers,
    });
  }
}
