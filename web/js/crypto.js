/* Credit: All VJS Author */
import { isArrayBuffer, isTypedArray } from "./util.js";

const {
  rand_uuid,
  rand_bytes,
  digest_sha1,
  digest_sha256,
  digest_sha384,
  digest_sha512,
} = globalThis.__crypto;

class DumpTypeError extends TypeError {
  constructor(name, input, pos = 0) {
    const msg = `args[${pos}] expected ${name} but got ${
      input?.constructor?.name ?? typeof input
    }`;
    super(msg);
  }
}

globalThis.crypto = {
  randomUUID: rand_uuid,
  getRandomValues: (input) => {
    if (isTypedArray(input)) {
      const { BYTES_PER_ELEMENT, length } = input;
      Reflect.construct(input.constructor, [
        rand_bytes(BYTES_PER_ELEMENT * length),
      ]).forEach((val, i) => (input[i] = val));
      return input;
    }
    throw new DumpTypeError("TypedArray", input);
  },
  subtle: {
    digest: (algo, buffer) => {
      if (typeof algo === "object") algo = algo.name ?? "";
      let sum;
      if (/\SHA-?1/.test(algo)) sum = digest_sha1;
      else if (/\SHA-?256/.test(algo)) sum = digest_sha256;
      else if (/\SHA-?384/.test(algo)) sum = digest_sha384;
      else if (/\SHA-?512/.test(algo)) sum = digest_sha512;
      else {
        return Promise.reject(
          new TypeError(`args[0] expected SHA-(1/256/384/512) but got ${algo}`),
        );
      }
      const noop = (fall) => new DumpTypeError("TypedArray", fall, 1);
      const stateBuf = (buf) => {
        if (isTypedArray(buf)) return 1;
        if (isArrayBuffer(buf)) return 2;
        return 0;
      };
      const state = stateBuf(buffer);
      return new Promise((ok, no) => {
        if (state === 1) return ok(sum(buffer.buffer));
        if (state === 2) return ok(sum(buffer));
        return no(noop(buf));
      });
    },
  },
};
