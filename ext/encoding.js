const { str_to_ab, ab_to_str } = globalThis.__bootstrap;

class TextEncoder {
  get encoding() {
    return "utf-8";
  }
  encode(input) {
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
    return ab_to_str(input.buffer);
  }
}

globalThis.TextEncoder = TextEncoder;
globalThis.TextDecoder = TextDecoder;
