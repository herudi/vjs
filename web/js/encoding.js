/* Credit: All VJS Author */

const { text_encode, text_decode, text_encode_into } = globalThis.__bootstrap;

class TextEncoder {
  get encoding() {
    return "utf-8";
  }
  encode(input) {
    return text_encode(input);
  }
  encodeInto(input, typed_array) {
    return text_encode_into(input, typed_array);
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
    return text_decode(input, opts);
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
