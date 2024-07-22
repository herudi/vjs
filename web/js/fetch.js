import { Request } from "./fetch/request.js";
import { Response } from "./fetch/response.js";
import { Headers } from "./fetch/headers.js";

const { core_fetch } = globalThis.__bootstrap;

async function fetch(input, opts = {}) {
  const req = new Request(input, opts);
  const url = req.url;
  const boundary = opts.body instanceof FormData
    ? Math.random().toString()
    : void 0;
  const body = typeof opts.body !== "string"
    ? await req.text(boundary)
    : opts.body;
  const res = await core_fetch(url, {
    method: opts.method ?? "GET",
    headers: req.headers.toJSON(),
    body: body,
    boundary: boundary,
  });
  const resInit = {};
  resInit.status = res.status;
  resInit.statusText = res.status_message;
  resInit.headers = res.header;
  resInit.url = url;
  return new Response(res.body, resInit);
}

globalThis.Headers = Headers;
globalThis.Request = Request;
globalThis.Response = Response;
globalThis.fetch = fetch;
