/* Credit: All VJS Author */
import { vjs_inspect } from "./util.js";
const { print, promise_state, util } = globalThis.__bootstrap;
const {
  isObject,
  isArray,
  isArrayBuffer,
  isBool,
  isFunc,
  isNumber,
  isRegExp,
  isString,
  isTypedArray,
  isTypeObject,
  isDate,
} = util;
const def_count = 25;
let count = 0;
const ett = {
  "\b": "\\b",
  "\t": "\\t",
  "\n": "\\n",
  "\f": "\\f",
  "\r": "\\r",
  '"': '\\"',
  "\\": "\\\\",
};
const esc = (v) => v.replace(/(?:[\b\t\n\f\r\"]|\\)/g, (e) => ett[e]);

Error.prototype[vjs_inspect] = function (format) {
  return "Error " + format({
    message: this.message,
    name: this.name || "Error",
    stack: this.stack || "",
  });
};
Promise.prototype[vjs_inspect] = function () {
  return `Promise { ${cyan(`<${promise_state(this)}>`)} }`;
};
Map.prototype[vjs_inspect] = function (format) {
  return `Map(${this.size}) ${format(Object.fromEntries(this.entries()))}`;
};
Set.prototype[vjs_inspect] = function (format) {
  return `Set(${this.size}) ${format(Array.from(this))}`;
};
function isCyclic(obj) {
  const seenObjects = [];
  function detect(obj) {
    if (obj && typeof obj === "object") {
      if (seenObjects.indexOf(obj) !== -1) {
        return true;
      }
      seenObjects.push(obj);
      for (const key in obj) {
        if (Object.hasOwn(obj, key) && detect(obj[key])) {
          return true;
        }
      }
    }
    return false;
  }
  return detect(obj);
}
function lookupFunction(x) {
  return x.prototype
    ? Object.getOwnPropertyDescriptor(x, "prototype").writable
      ? "Function"
      : "class"
    : x.constructor.name === "AsyncFunction"
    ? "AsyncFunction"
    : "Function";
}
function formatColour(msg, start, end) {
  return `\x1b[${start}m${msg}\x1b[${end}m`;
}
const yellow = (val) => formatColour(val, 33, 39);
const green = (val) => formatColour(val, 32, 39);
const cyan = (val) => formatColour(val, 36, 39);
const red = (val) => formatColour(val, 31, 39);
const blue = (val) => formatColour(val, 34, 39);
const c_name = (val) => val?.constructor?.name;
function formatValue(val, is_str, ctx) {
  if (isNumber(val)) return yellow(val);
  if (isObject(val)) return formatObject(val, ctx);
  if (isString(val)) return is_str ? val : green(`"${esc(val)}"`);
  if (isArray(val)) return formatArray(val, ctx);
  if (isBool(val)) return yellow(val);
  if (isFunc(val)) {
    const name = lookupFunction(val);
    return cyan(`[${name}: ${val.name || "(anonymous)"}]`);
  }
  if (isRegExp(val)) return red(val.toString());
  const my_name = c_name(val);
  if (isArrayBuffer(val) || isTypedArray(val)) {
    let data;
    if (val instanceof ArrayBuffer) {
      val = new Uint8Array(val);
      data = formatArray(val, ctx);
    } else {
      data = formatArray(val, ctx);
    }
    return `${my_name}(${val.length}) ${data}`;
  }
  if (isDate(val)) return blue(val.toISOString());
  if (my_name === "Symbol") return green(val.toString());
  if (my_name !== void 0) return formatClass(val, ctx);
  return val;
}
function format(val, is_str) {
  const res = formatValue(val, is_str);
  return res;
}
function formatPrintLog(...args) {
  print(...args.map((val) => format(val, isString(val))));
}
function createContext(ctx) {
  if (ctx === void 0) {
    ctx = {};
    ctx.id = count++;
    ctx.gap = "  ";
  }
  return ctx;
}
function countObject(obj) {
  let count = 0;
  for (const k in obj) {
    const v = obj[k];
    if (v != null) {
      if (isObject(v)) {
        count += countObject(v);
      } else if (isArray(v)) {
        count += countArray(v);
      } else {
        count += k.length + (String(v).length ?? 0);
      }
    }
  }
  return count;
}
function countArray(arr) {
  let count = 0;
  const len = arr.length;
  for (let i = 0; i < len; i++) {
    const v = arr[i];
    if (v != null) {
      if (isObject(v)) {
        count += countObject(v);
      } else if (isArray(v)) {
        count += countArray(v);
      } else {
        count += String(v).length ?? 0;
      }
    }
  }
  return count;
}
function formatArray(arr, ctx) {
  const len = arr.length;
  if (len === 0) return "[]";
  let out = "";
  if (countArray(arr) >= def_count) {
    ctx = createContext(ctx);
    out = "[\n";
  } else {
    ctx = void 0;
    out = "[ ";
  }
  const hasCtx = ctx !== void 0;
  const last = len - 1;
  const close = hasCtx ? ctx.gap.slice(0, -2) + "]" : " ]";
  for (let i = 0; i < len; i++) {
    const cc = last === i ? "" : ", ";
    if (hasCtx) {
      let gap = ctx.gap;
      const val = arr[i];
      if (isTypeObject(val)) gap += "  ";
      const ret = formatValue(val, void 0, { ...ctx, gap });
      out += `${ctx.gap}${ret}${cc}\n`;
    } else {
      const val = arr[i];
      const ret = formatValue(val);
      out += `${ret}${cc}`;
    }
  }
  out += close;
  return out;
}
function formatClass(cls, ctx) {
  if (cls[vjs_inspect] !== void 0) {
    return cls[vjs_inspect]((data) => {
      return formatValue(data, void 0, ctx);
    });
  }
  return `${c_name(cls)} ${formatObject(cls, ctx)}`;
}

function formatObject(obj, ctx) {
  const keys = Object.keys(obj);
  const len = keys.length;
  if (len === 0) return "{}";
  let out = "";
  if (countObject(obj) >= def_count) {
    ctx = createContext(ctx);
    out = "{\n";
  } else {
    ctx = void 0;
    out = "{ ";
  }
  const hasCtx = ctx !== void 0;
  const close = hasCtx ? ctx.gap.slice(0, -2) + "}" : " }";
  const last = len - 1;
  keys.forEach((key, i) => {
    const cc = last === i ? "" : ", ";
    const val = obj[key];
    if (hasCtx) {
      let gap = ctx.gap;
      if (isTypeObject(val)) gap += "  ";
      const ret = isCyclic(val)
        ? cyan("[Circular]")
        : formatValue(val, void 0, { ...ctx, gap });
      out += `${ctx.gap}${key}: ${ret}${cc}\n`;
    } else {
      const ret = isCyclic(val) ? cyan("[Circular]") : formatValue(val);
      out += `${key}: ${ret}${cc}`;
    }
  });
  out += close;
  return out;
}
globalThis.console = {
  log: formatPrintLog,
  info: formatPrintLog,
  trace: formatPrintLog,
  debug: formatPrintLog,
  error: formatPrintLog,
  warn: formatPrintLog,
};
