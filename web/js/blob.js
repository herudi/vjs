// Credit: https://github.com/node-fetch/fetch-blob/blob/main/index.js

import { vjs_inspect } from "./util.js";

const POOL_SIZE = 65536;

async function* toIterator(parts, clone) {
  for (const part of parts) {
    if (ArrayBuffer.isView(part)) {
      if (clone) {
        let position = part.byteOffset;
        const end = part.byteOffset + part.byteLength;
        while (position !== end) {
          const size = Math.min(end - position, POOL_SIZE);
          const chunk = part.buffer.slice(position, position + size);
          position += chunk.byteLength;
          yield new Uint8Array(chunk);
        }
      } else {
        yield part;
      }
    } else {
      yield* part.stream();
    }
  }
}

class Blob {
  _parts = [];
  #type = "";
  _size = 0;
  constructor(blobParts = [], options = {}) {
    if (typeof blobParts !== "object" || blobParts === null) {
      throw new TypeError(
        "Failed to construct 'Blob': The provided value cannot be converted to a sequence.",
      );
    }
    if (typeof blobParts[Symbol.iterator] !== "function") {
      throw new TypeError(
        "Failed to construct 'Blob': The object must have a callable @@iterator property.",
      );
    }
    if (typeof options !== "object" && typeof options !== "function") {
      throw new TypeError(
        "Failed to construct 'Blob': parameter 2 cannot convert to dictionary.",
      );
    }
    if (options === null) options = {};
    const encoder = new TextEncoder();
    for (const element of blobParts) {
      let part;
      if (ArrayBuffer.isView(element)) {
        part = new Uint8Array(
          element.buffer.slice(
            element.byteOffset,
            element.byteOffset + element.byteLength,
          ),
        );
      } else if (element instanceof ArrayBuffer) {
        part = new Uint8Array(element.slice(0));
      } else if (element instanceof Blob) {
        part = element;
      } else {
        part = encoder.encode(`${element}`);
      }
      const size = ArrayBuffer.isView(part) ? part.byteLength : part.size;
      if (size) {
        this._size += size;
        this._parts.push(part);
      }
    }
    const type = options.type === undefined ? "" : String(options.type);
    this.#type = /^[\x20-\x7E]*$/.test(type) ? type : "";
  }
  get size() {
    return this._size;
  }
  get type() {
    return this.#type;
  }
  async text() {
    const decoder = new TextDecoder();
    let str = "";
    for await (const part of toIterator(this._parts, false)) {
      str += decoder.decode(part, { stream: true });
    }
    str += decoder.decode();
    return str;
  }
  async arrayBuffer() {
    const data = new Uint8Array(this.size);
    let offset = 0;
    for await (const chunk of toIterator(this._parts, false)) {
      data.set(chunk, offset);
      offset += chunk.length;
    }

    return data.buffer;
  }

  stream() {
    const it = toIterator(this._parts, true);
    return new globalThis.ReadableStream({
      type: "bytes",
      async pull(ctrl) {
        const chunk = await it.next();
        chunk.done ? ctrl.close() : ctrl.enqueue(chunk.value);
      },

      async cancel() {
        await it.return();
      },
    });
  }
  slice(start = 0, end = this.size, type = "") {
    const { size } = this;
    let relativeStart = start < 0
      ? Math.max(size + start, 0)
      : Math.min(start, size);
    let relativeEnd = end < 0 ? Math.max(size + end, 0) : Math.min(end, size);

    const span = Math.max(relativeEnd - relativeStart, 0);
    const parts = this._parts;
    const blobParts = [];
    let added = 0;

    for (const part of parts) {
      if (added >= span) {
        break;
      }
      const size = ArrayBuffer.isView(part) ? part.byteLength : part.size;
      if (relativeStart && size <= relativeStart) {
        relativeStart -= size;
        relativeEnd -= size;
      } else {
        let chunk;
        if (ArrayBuffer.isView(part)) {
          chunk = part.subarray(relativeStart, Math.min(size, relativeEnd));
          added += chunk.byteLength;
        } else {
          chunk = part.slice(relativeStart, Math.min(size, relativeEnd));
          added += chunk.size;
        }
        relativeEnd -= size;
        blobParts.push(chunk);
        relativeStart = 0; // All next sequential parts should start at 0
      }
    }

    const blob = new Blob([], { type: `${type}` });
    blob._size = span;
    blob._parts = blobParts;

    return blob;
  }

  [vjs_inspect]() {
    return {
      size: this.size,
      type: this.type,
    };
  }
}
Object.defineProperties(Blob.prototype, {
  size: { enumerable: true },
  type: { enumerable: true },
  slice: { enumerable: true },
});
class File extends Blob {
  #lastModified = 0;
  #name = "";
  constructor(fileBits, fileName, options = {}) {
    if (arguments.length < 2) {
      throw new TypeError(
        `Failed to construct 'File': 2 arguments required, but only ${arguments.length} present.`,
      );
    }
    super(fileBits, options);
    if (options === null) options = {};
    const lastModified = options.lastModified === undefined
      ? Date.now()
      : Number(options.lastModified);
    if (!Number.isNaN(lastModified)) {
      this.#lastModified = lastModified;
    }
    this.#name = String(fileName);
  }
  get name() {
    return this.#name;
  }
  get lastModified() {
    return this.#lastModified;
  }
  [vjs_inspect]() {
    return {
      size: this.size,
      type: this.type,
      name: this.name,
      lastModified: this.lastModified,
    };
  }
}
globalThis.Blob = Blob;
globalThis.File = File;
