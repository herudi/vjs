const { print } = globalThis.__bootstrap;
const isObject = (val) => val?.constructor?.name === "Object";
const isArray = Array.isArray;
const KEY = "@@__VJS_REP__@@";
const REG = /"@@__VJS_REP__@@|@@__VJS_REP__@@"/g;
function isFunction(x) {
  return typeof x === "function"
    ? x.prototype
      ? Object.getOwnPropertyDescriptor(x, "prototype").writable
        ? "Function"
        : "Class"
      : x.constructor.name === "AsyncFunction"
      ? "AsyncFunction"
      : "Function"
    : "";
}
const stringify = JSON.stringify;
function rep(k, v) {
  if (typeof v === "function") {
    const fn = isFunction(v);
    if (fn) {
      return `${KEY}[${fn}: ${v.name || k}]${KEY}`;
    }
  }
  if (typeof v === "object") {
    if (isObject(v) || isArray(v)) {
      return v;
    }
    if (v instanceof RegExp) {
      return `${KEY}${v.toString()}${KEY}`;
    }
    const c_name = v.constructor?.name;
    if (c_name !== void 0) {
      return v;
    }
  }
  return v;
}
const objToString = (val) => {
  const str = stringify(val, rep, 2);
  return str.replace(REG, "");
};
const formatter = (val) => {
  if (typeof val === "object") {
    if (isObject(val) || isArray(val)) {
      if (val.__vjs_global__) {
        return "GlobalThis";
      }
      return objToString(val);
    }
    if (val instanceof RegExp) {
      return val;
    }
    const c_name = val.constructor?.name;
    if (c_name !== void 0) {
      if (val instanceof Uint8Array) {
        return `${c_name}(${val.byteLength}) [${
          val.toString().replace(/,/g, ", ")
        }]`;
      }
      if (val?.toJSON) {
        return `${c_name} ${objToString(val.toJSON())}`;
      }
      return `${c_name} ${objToString(val)}`;
    }
  }
  if (typeof val === "function") {
    const fn = isFunction(val);
    if (fn) {
      return `[${fn}: ${val.name || "(anonymous)"}]`;
    }
  }
  return val;
};

class Console {
  log = (...args) => {
    print(...args.map((val) => {
      return formatter(val);
    }));
  };
  info = (...args) => {
    print(...args.map((val) => {
      return formatter(val);
    }));
  };
  trace = (...args) => {
    print(...args.map((val) => {
      return formatter(val);
    }));
  };
  debug = (...args) => {
    print(...args.map((val) => {
      return formatter(val);
    }));
  };
  error = (...args) => {
    print(...args.map((val) => {
      return formatter(val);
    }));
  };
  warn = (...args) => {
    print(...args.map((val) => {
      return formatter(val);
    }));
  };
}

globalThis.console = new Console();
