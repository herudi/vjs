const { isTypedArray, isArrayBuffer } = globalThis.__bootstrap.util;
const encoder = new TextEncoder();
const decoder = new TextDecoder();
function streamToStr(stream) {
  const reader = stream.getReader();
  let result = "";
  async function read() {
    const { done, value } = await reader.read();
    if (done) {
      return result;
    }
    result += decoder.decode(value, { stream: true });
    return read();
  }
  return read();
}
const toStream = (data) =>
  new ReadableStream({
    start(ctrl) {
      ctrl.enqueue(data);
      ctrl.close();
    },
  });
export class Body {
  #body = {};
  #bodyUsed = false;
  constructor(body) {
    if (body != null) {
      if (typeof body === "string") {
        this.#body.text = body;
      } else if (body instanceof URLSearchParams) {
        this.#body.text = body.toString();
      } else if (body instanceof FormData) {
        this.#body.form = body;
        this.#body.blob = body["_blob"];
      } else if (body instanceof ReadableStream) {
        this.#body.stream = body;
      } else if (body instanceof Blob) {
        this.#body.blob = body;
      } else if (isArrayBuffer(body) || isTypedArray(body)) {
        body = isArrayBuffer(body) ? body : body.buffer;
        this.#body.arrayBuffer = body;
        this.#body.text = decoder.decode(body);
      }
    }
  }
  #checkUpdateBody() {
    if (this.#bodyUsed) {
      throw new TypeError("Body already consumed.");
    }
    this.#bodyUsed = true;
  }
  #realBlob(code) {
    return typeof this.#body.blob === "function"
      ? this.#body.blob(code)
      : this.#body.blob;
  }
  get bodyUsed() {
    return this.#bodyUsed;
  }
  get body() {
    if (this.#body.stream !== void 0) {
      return this.#body.stream;
    }
    if (this.#body.text !== void 0) {
      return toStream(encoder.encode(this.#body.text));
    }
    if (this.#body.blob !== void 0) {
      return this.#realBlob().stream();
    }
    if (this.#body.arrayBuffer !== void 0) {
      return toStream(new Uint8Array(this.#body.arrayBuffer));
    }
    return null;
  }

  text(code) {
    this.#checkUpdateBody();
    if (this.#body.text !== void 0) {
      return Promise.resolve(this.#body.text);
    }
    if (this.#body.arrayBuffer !== void 0) {
      return Promise.resolve(decoder.decode(this.#body.arrayBuffer));
    }
    if (this.#body.blob !== void 0) {
      const blob = this.#realBlob(code);
      return blob.text();
    }
    if (this.#body.stream !== void 0) {
      return streamToStr(this.#body.stream);
    }
    return Promise.resolve("");
  }

  json() {
    return this.text().then(JSON.parse);
  }

  formData() {
    this.#checkUpdateBody();
    if (this.#body.form !== void 0) {
      return Promise.resolve(this.#body.form);
    }
    throw new TypeError("Can't read form-data from body");
  }

  blob() {
    this.#checkUpdateBody();
    if (this.#body.blob !== void 0) {
      return Promise.resolve(this.#realBlob());
    }
    throw new TypeError("Can't read blob from body");
  }

  arrayBuffer() {
    if (this.#body.arrayBuffer !== void 0) {
      this.#checkUpdateBody();
      return Promise.resolve(this.#body.arrayBuffer);
    }
    return this.text().then(encoder.encode);
  }
}
