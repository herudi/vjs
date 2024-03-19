/* Credit: All VJS Author */

import { isArrayBuffer, isTypedArray } from "./util.js";

const { str_to_ab, ab_to_str } = globalThis.__encoding;

class TextEncoder {
  get encoding() {
    return "utf-8";
  }
  encode(input) {
    if (input === void 0) return new Uint8Array();
    return new Uint8Array(str_to_ab(input));
  }
  encodeInto(text, array) {
    const buf = this.encode(text);
    const ret = {
      read: text.length,
      written: buf.length,
    };
    if (buf.length > array.length) {
      ret.read = parseInt(array.length / buf.length * ret.read);
      ret.written = array.length;
    }
    array.set(buf, 0);
    return ret;
  }
}
class TextDecoder {
  #label;
  #opts;
  constructor(label = "utf-8", opts = {}) {
    this.#label = label;
    this.#opts = opts;
  }
  get encoding() {
    return this.#label;
  }
  get fatal() {
    return this.#opts.fatal ?? false;
  }
  get ignoreBOM() {
    return this.#opts.ignoreBOM ?? false;
  }
  decode(input, opts = {}) {
    if (input === void 0) return "";
    if (isArrayBuffer(input)) return ab_to_str(input);
    if (isTypedArray(input)) return ab_to_str(input.buffer);
    throw new TypeError(`args[0] not TypedArray`);
  }
}

// Credit: https://github.com/GoogleChromeLabs/text-encode-transform-polyfill

const codec = Symbol("codec");
const transform = Symbol("transform");

class TextEncoderStream {
  constructor() {
    this[codec] = new TextEncoder();
    this[transform] = new TransformStream(
      new TextEncodeTransformer(this[codec]),
    );
  }
}

class TextDecoderStream {
  constructor(encoding, opts) {
    this[codec] = new TextDecoder(encoding, opts);
    this[transform] = new TransformStream(
      new TextDecodeTransformer(this[codec]),
    );
  }
}

class TextEncodeTransformer {
  #encoder;
  #carry;
  constructor() {
    this.#encoder = new TextEncoder();
    this.#carry = void 0;
  }

  transform(chunk, ctrl) {
    chunk = String(chunk);
    if (this.#carry !== void 0) {
      chunk = this.#carry + chunk;
      this.#carry = void 0;
    }
    const term = chunk.charCodeAt(chunk.length - 1);
    if (term >= 0xD800 && term < 0xDC00) {
      this.#carry = chunk.substring(chunk.length - 1);
      chunk = chunk.substring(0, chunk.length - 1);
    }
    const enc = this.#encoder.encode(chunk);
    if (enc.length > 0) ctrl.enqueue(enc);
  }

  flush(ctrl) {
    if (this.#carry !== void 0) {
      ctrl.enqueue(this.#encoder.encode(this.#carry));
      this.#carry = void 0;
    }
  }
}

class TextDecodeTransformer {
  #decoder;
  constructor(decoder = {}) {
    this.#decoder = new TextDecoder(decoder.encoding, {
      fatal: decoder.fatal,
      ignoreBOM: decoder.ignoreBOM,
    });
  }

  transform(chunk, ctrl) {
    const dec = this.#decoder.decode(chunk, { stream: true });
    if (dec != "") ctrl.enqueue(decoded);
  }

  flush(ctrl) {
    const out = this.#decoder.decode();
    if (out !== "") ctrl.enqueue(out);
  }
}

globalThis.TextEncoder = TextEncoder;
globalThis.TextDecoder = TextDecoder;
globalThis.TextEncoderStream = TextEncoderStream;
globalThis.TextDecoderStream = TextDecoderStream;
