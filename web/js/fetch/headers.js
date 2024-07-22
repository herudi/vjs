import { vjs_inspect } from "../util.js";

const toKey = (k) => k.toLowerCase();
const hasOwn = (obj, k) => Object.hasOwn(obj, k);
function makeIterator(items) {
  const iterator = {
    next: function () {
      const value = items.shift();
      return { done: value === undefined, value: value };
    },
  };
  if (support.iterable) {
    iterator[Symbol.iterator] = function () {
      return iterator;
    };
  }
  return iterator;
}

export class Headers {
  #map = {};
  constructor(headers) {
    if (headers != null) {
      if (headers instanceof Headers) {
        headers.forEach((val, key) => {
          this.append(key, val);
        }, this);
      } else if (Array.isArray(headers)) {
        headers.forEach((header) => {
          if (header.length != 2) {
            throw new TypeError(
              "Headers constructor: expected name/value pair to be length 2, found" +
                header.length,
            );
          }
          this.append(header[0], header[1]);
        }, this);
      } else {
        Object.getOwnPropertyNames(headers).forEach((key) => {
          this.append(key, headers[key]);
        }, this);
      }
    }
  }
  append(key, val) {
    key = toKey(key);
    const oldValue = this.#map[key];
    this.#map[key] = oldValue ? oldValue + ", " + val : val;
  }
  delete(key) {
    delete this.#map[toKey(key)];
  }
  get(key) {
    key = toKey(key);
    return this.has(key) ? this.#map[key] : null;
  }
  has(key) {
    return hasOwn(this.#map, toKey(key));
  }
  set(key, val) {
    this.#map[toKey(key)] = val;
  }
  forEach(cb, thisArg) {
    for (const key in this.#map) {
      if (hasOwn(this.#map, key)) {
        cb.call(thisArg, this.#map[key], key, this);
      }
    }
  }
  keys() {
    const items = [];
    this.forEach((_, key) => {
      items.push(key);
    });
    return makeIterator(items);
  }
  values() {
    const items = [];
    this.forEach((val) => {
      items.push(val);
    });
    return makeIterator(items);
  }
  entries() {
    const items = [];
    this.forEach((val, key) => {
      items.push([key, val]);
    });
    return makeIterator(items);
  }
  getSetCookie() {
    return this.get("Set-Cookie").split(";") ?? [];
  }
  toJSON() {
    return this.#map;
  }
  [vjs_inspect](format) {
    return "Headers " + format(this.toJSON());
  }
}
Headers.prototype[Symbol.iterator] = Headers.prototype.entries;
