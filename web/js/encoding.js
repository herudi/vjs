/* Credit: All VJS Author */
const { str_to_ab, ab_to_str } = globalThis.__encoding;

class TextEncoder {
  get encoding() {
    return "utf-8";
  }
  encode(input) {
    if (input === void 0) return new Uint8Array();
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
    if (input === void 0) return "";
    const buf = input?.buffer;
    if (buf instanceof ArrayBuffer) {
      return ab_to_str(buf);
    }
    throw new TypeError(`args[0] not ArrayBufferView`);
  }
}

globalThis.TextEncoder = TextEncoder;
globalThis.TextDecoder = TextDecoder;
