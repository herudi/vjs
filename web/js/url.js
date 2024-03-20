/* Credit: All VJS Author */
import { vjs_inspect } from "./util.js";
// Credit URLSearchParams => https://github.com/jerrybendy/url-search-params-polyfill/blob/master/index.js
const isArray = Array.isArray;
function decode(str) {
  return str
    .replace(/[ +]/g, "%20")
    .replace(/(%[a-f0-9]{2})+/ig, function (match) {
      return decodeURIComponent(match);
    });
}
function hasOwnProperty(obj, prop) {
  return Object.prototype.hasOwnProperty.call(obj, prop);
}
function appendTo(dict, name, value) {
  let val = typeof value === "string" ? value : (
    value !== null && value !== undefined &&
      typeof value.toString === "function"
      ? value.toString()
      : JSON.stringify(value)
  );
  if (hasOwnProperty(dict, name)) {
    dict[name].push(val);
  } else {
    dict[name] = [val];
  }
}
function parse(search) {
  let dict = {};
  if (typeof search === "object") {
    if (isArray(search)) {
      for (let i = 0; i < search.length; i++) {
        let item = search[i];
        if (isArray(item) && item.length === 2) {
          appendTo(dict, item[0], item[1]);
        } else {
          throw new TypeError(
            "Failed to construct 'URLSearchParams': Sequence initializer must only contain pair elements",
          );
        }
      }
    } else {
      for (let key in search) {
        if (search.hasOwnProperty(key)) {
          appendTo(dict, key, search[key]);
        }
      }
    }
  } else {
    let pairs = search.split("&");
    for (let j = 0; j < pairs.length; j++) {
      let value = pairs[j],
        index = value.indexOf("=");
      if (-1 < index) {
        appendTo(
          dict,
          decode(value.slice(0, index)),
          decode(value.slice(index + 1)),
        );
      } else {
        if (value) {
          appendTo(dict, decode(value), "");
        }
      }
    }
  }
  return dict;
}
function encode(str) {
  let replace = {
    "!": "%21",
    "'": "%27",
    "(": "%28",
    ")": "%29",
    "~": "%7E",
    "%20": "+",
    "%00": "\x00",
  };
  return encodeURIComponent(str).replace(
    /[!'\(\)~]|%20|%00/g,
    function (match) {
      return replace[match];
    },
  );
}
class URLSearchParams {
  #query = void 0;
  constructor(search) {
    if (search[0] === "?") {
      search = search.slice(1);
    }
    this.#query = parse(search);
  }

  append(k, v) {
    appendTo(this.#query, k, v);
  }
  set(k, v) {
    this.#query[k] = ["" + v];
  }
  has(k) {
    return hasOwnProperty(this.#query, k);
  }
  get(k) {
    return this.has(k) ? this.#query[k][0] : null;
  }
  getAll(k) {
    return this.has(k) ? this.#query[k].slice(0) : [];
  }
  delete(k) {
    delete this.#query[k];
  }
  toString() {
    let dict = this.#query, query = [], i, key, name, value;
    for (key in dict) {
      name = encode(key);
      for (i = 0, value = dict[key]; i < value.length; i++) {
        query.push(name + "=" + encode(value[i]));
      }
    }
    return query.join("&");
  }
  [vjs_inspect](format) {
    return "URLSearchParams " + format(this.#query);
  }
}
globalThis.URLSearchParams = URLSearchParams;
const proto = globalThis.URLSearchParams.prototype;
proto[Symbol.toStringTag] = "URLSearchParams";
proto.forEach = function (callback, thisArg) {
  const dict = parse(this.toString());
  Object.getOwnPropertyNames(dict).forEach(function (name) {
    dict[name].forEach(function (value) {
      callback.call(thisArg, value, name, this);
    }, this);
  }, this);
};
proto.sort = function () {
  let dict = parse(this.toString()), keys = [], k, i, j;
  for (k in dict) {
    keys.push(k);
  }
  keys.sort();
  for (i = 0; i < keys.length; i++) {
    this["delete"](keys[i]);
  }
  for (i = 0; i < keys.length; i++) {
    let key = keys[i], values = dict[key];
    for (j = 0; j < values.length; j++) {
      this.append(key, values[j]);
    }
  }
};
proto.keys = function () {
  let items = [];
  this.forEach(function (_, name) {
    items.push(name);
  });
  return makeIterator(items);
};
proto.values = function () {
  let items = [];
  this.forEach(function (item) {
    items.push(item);
  });
  return makeIterator(items);
};
proto.entries = function () {
  let items = [];
  this.forEach(function (item, name) {
    items.push([name, item]);
  });
  return makeIterator(items);
};
Object.defineProperty(proto, "size", {
  get: function () {
    let dict = parse(this.toString());
    if (proto === this) {
      throw new TypeError("Illegal invocation at URLSearchParams.invokeGetter");
    }
    return Object.keys(dict).reduce(function (prev, cur) {
      return prev + dict[cur].length;
    }, 0);
  },
});
proto[Symbol.iterator] = proto.entries;
function makeIterator(arr) {
  let iterator = {
    next: function () {
      let value = arr.shift();
      return { done: value === undefined, value: value };
    },
  };
  iterator[Symbol.iterator] = function () {
    return iterator;
  };
  return iterator;
}

const iof8 = (a, b = "/") => a.indexOf(b, 8);

class URL {
  #pathname = void 0;
  #protocol = void 0;
  #host = void 0;
  #hostname = void 0;
  #port = void 0;
  #hash = void 0;
  #username = void 0;
  #password = void 0;
  #idx = -1;
  constructor(input, base) {
    if (base instanceof URL) {
      base = base.origin;
    }
    if (input instanceof URL) {
      input = base ? input.pathname : input.href;
    }
    this.href = base ? base + input : input;
    if (/^[a-zA-z]+:\/\/.*/.test(this.href) === false) {
      throw new TypeError(`Invalid URL ${this.href}`);
    }
    const idx = this.#idx = iof8(this.href, "?");
    this.search = idx !== -1 ? this.href.slice(idx) : "";
  }
  static canParse(input, base) {
    try {
      new URL(input, base);
      return true;
    } catch {
      return false;
    }
  }
  static createObjectURL() {
    throw new Error("createObjectURL not implemented yet.");
  }
  static revokeObjectURL() {
    throw new Error("revokeObjectURL not implemented yet.");
  }
  get origin() {
    return this.href.slice(0, iof8(this.href));
  }
  get protocol() {
    return this.#protocol ?? this.href.match(/[^/:]*/)[0] + ":";
  }
  set protocol(val) {
    this.#protocol = val;
  }
  #oriHost() {
    return this.href.match(/:\/+(.*)/)[1].split("/")[0];
  }
  get host() {
    if (this.#host) return this.#host;
    const host = this.#oriHost();
    return host.includes("@") ? host.slice(host.indexOf("@") + 1) : host;
  }
  set host(val) {
    this.#host = val;
  }
  get username() {
    if (this.#username) return this.#username;
    const val = this.#oriHost();
    return val.includes("@")
      ? val.slice(0, val.indexOf("@")).split(":")[0] ?? ""
      : "";
  }
  set username(val) {
    this.#username = val;
  }
  get password() {
    if (this.#password) return this.#password;
    const val = this.#oriHost();
    return val.includes("@")
      ? val.slice(0, val.indexOf("@")).split(":")[1] ?? ""
      : "";
  }
  set password(val) {
    this.#password = val;
  }
  get hostname() {
    return this.#hostname ?? this.host.split(":")[0] ?? "";
  }
  set hostname(val) {
    this.#hostname = val;
  }
  get port() {
    return this.#port ?? this.host.split(":")[1] ?? "";
  }
  set port(val) {
    this.#port = val;
  }
  #oriPathname() {
    const idx = iof8(this.href);
    return this.#idx !== -1
      ? this.href.slice(idx, this.#idx)
      : this.href.slice(idx);
  }
  get hash() {
    if (this.#hash) return this.#hash;
    const hash = this.#oriPathname();
    if (hash.includes("#")) {
      return hash.slice(hash.indexOf("#"));
    }
    return "";
  }
  set hash(val) {
    this.#hash = val;
  }
  get pathname() {
    if (this.#pathname) return this.#pathname;
    const path = this.#oriPathname();
    if (path.includes("#")) {
      return path.slice(0, path.indexOf("#"));
    }
    return path;
  }
  set pathname(val) {
    this.#pathname = val;
  }
  get searchParams() {
    return new URLSearchParams(this.search);
  }
  toString() {
    return this.href;
  }
  toJSON() {
    return this.href;
  }
  [vjs_inspect](format) {
    return "URL " + format({
      href: this.href,
      origin: this.origin,
      protocol: this.protocol,
      username: this.username,
      password: this.password,
      host: this.host,
      hostname: this.hostname,
      port: this.port,
      pathname: this.pathname,
      search: this.search,
      searchParams: this.searchParams,
      hash: this.hash,
    });
  }
}

globalThis.URL = URL;
