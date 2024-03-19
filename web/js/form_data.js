/* formdata-polyfill. MIT License. Jimmy Wärting <https://jimmy.warting.se/opensource> */
/* global FormData self Blob File */
/* eslint-disable no-inner-declarations */

import { vjs_inspect } from "./util.js";

function ensureArgs(args, expected) {
  if (args.length < expected) {
    throw new TypeError(
      `${expected} argument required, but only ${args.length} present.`,
    );
  }
}

function normalizeArgs(name, value, filename) {
  if (value instanceof Blob) {
    filename = filename !== undefined
      ? String(filename + "")
      : typeof value.name === "string"
      ? value.name
      : "blob";

    if (
      value.name !== filename ||
      Object.prototype.toString.call(value) === "[object Blob]"
    ) {
      value = new File([value], filename);
    }
    return [String(name), value];
  }
  return [String(name), String(value)];
}

function normalizeLinefeeds(value) {
  return value.replace(/\r?\n|\r/g, "\r\n");
}

function each(arr, cb) {
  for (let i = 0; i < arr.length; i++) {
    cb(arr[i]);
  }
}

const escapeStr = (str) =>
  str.replace(/\n/g, "%0A").replace(/\r/g, "%0D").replace(/"/g, "%22");

class FormData {
  #data = [];
  constructor(form) {
    const self = this;
    form && each(form.elements, (elm) => {
      if (
        !elm.name ||
        elm.disabled ||
        elm.type === "submit" ||
        elm.type === "button" ||
        elm.matches("form fieldset[disabled] *")
      ) return;

      if (elm.type === "file") {
        const files = elm.files && elm.files.length
          ? elm.files
          : [new File([], "", { type: "application/octet-stream" })]; // #78
        each(files, (file) => {
          self.append(elm.name, file);
        });
      } else if (elm.type === "select-multiple" || elm.type === "select-one") {
        each(elm.options, (opt) => {
          !opt.disabled && opt.selected && self.append(elm.name, opt.value);
        });
      } else if (elm.type === "checkbox" || elm.type === "radio") {
        if (elm.checked) self.append(elm.name, elm.value);
      } else {
        const value = elm.type === "textarea"
          ? normalizeLinefeeds(elm.value)
          : elm.value;
        self.append(elm.name, value);
      }
    });
  }
  append(name, value, filename) {
    ensureArgs(arguments, 2);
    this.#data.push(normalizeArgs(name, value, filename));
  }
  delete(name) {
    ensureArgs(arguments, 1);
    const result = [];
    name = String(name);
    each(this.#data, (entry) => {
      entry[0] !== name && result.push(entry);
    });
    this.#data = result;
  }
  *entries() {
    for (var i = 0; i < this.#data.length; i++) {
      yield this.#data[i];
    }
  }
  forEach(callback, thisArg) {
    ensureArgs(arguments, 1);
    for (const [name, value] of this) {
      callback.call(thisArg, value, name, this);
    }
  }
  get(name) {
    ensureArgs(arguments, 1);
    const entries = this.#data;
    name = String(name);
    for (let i = 0; i < entries.length; i++) {
      if (entries[i][0] === name) {
        return entries[i][1];
      }
    }
    return null;
  }
  getAll(name) {
    ensureArgs(arguments, 1);
    const result = [];
    name = String(name);
    each(this.#data, (data) => {
      data[0] === name && result.push(data[1]);
    });

    return result;
  }
  has(name) {
    ensureArgs(arguments, 1);
    name = String(name);
    for (let i = 0; i < this.#data.length; i++) {
      if (this.#data[i][0] === name) {
        return true;
      }
    }
    return false;
  }
  *keys() {
    for (const [name] of this) {
      yield name;
    }
  }
  set(name, value, filename) {
    ensureArgs(arguments, 2);
    name = String(name);
    const result = [];
    const args = normalizeArgs(name, value, filename);
    let replace = true;
    each(this.#data, (data) => {
      data[0] === name
        ? replace && (replace = !result.push(args))
        : result.push(data);
    });

    replace && result.push(args);

    this.#data = result;
  }
  *values() {
    for (const [, value] of this) {
      yield value;
    }
  }
  ["_blob"]() {
    const boundary = "----formdata-polyfill-" + Math.random(),
      chunks = [],
      p = `--${boundary}\r\nContent-Disposition: form-data; name="`;
    this.forEach((value, name) =>
      typeof value == "string"
        ? chunks.push(
          p + escapeStr(normalizeLinefeeds(name)) +
            `"\r\n\r\n${normalizeLinefeeds(value)}\r\n`,
        )
        : chunks.push(
          p + escapeStr(normalizeLinefeeds(name)) +
            `"; filename="${escapeStr(value.name)}"\r\nContent-Type: ${
              value.type || "application/octet-stream"
            }\r\n\r\n`,
          value,
          `\r\n`,
        )
    );
    chunks.push(`--${boundary}--`);
    return new Blob(chunks, {
      type: "multipart/form-data; boundary=" + boundary,
    });
  }
  [Symbol.iterator]() {
    return this.entries();
  }
  toString() {
    return "[object FormData]";
  }
  [vjs_inspect]() {
    return Object.fromEntries(this.entries());
  }
}

globalThis.FormData = FormData;
