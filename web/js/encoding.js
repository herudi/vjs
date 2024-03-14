const { str_to_ab, ab_to_str } = globalThis.__encoding;

class TextEncoder {
  get encoding() {
    return "utf-8";
  }
  encode(input) {
    if (input === void 0) {
      throw new TypeError("args[0] is required");
    }
    return new Uint8Array(str_to_ab(input));
  }
  encodeInto(input, uint) {
    // soon.
  }
}
class TextDecoder {
  get encoding() {
    return "utf-8";
  }
  decode(input) {
    if (input === void 0) {
      throw new TypeError("args[0] is required");
    }
    return ab_to_str(input.buffer);
  }
}

globalThis.TextEncoder = TextEncoder;
globalThis.TextDecoder = TextDecoder;

delete globalThis.__encoding;
