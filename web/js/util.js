/* Credit: All VJS Author */
export const isObject = (v) => v?.constructor?.name === "Object";
export const isTypeObject = (v) => typeof v === "object";
export const isArray = Array.isArray;
export const isString = (v) => typeof v === "string";
export const isNumber = (v) => typeof v === "number";
export const isBool = (v) => typeof v === "boolean";
export const isFunc = (v) => typeof v === "function";
export const isRegExp = (v) => v instanceof RegExp;
export const isArrayBuffer = (v) => v instanceof ArrayBuffer;
export const isPromise = (v) => v instanceof Promise;
export const isTypedArray = (v) =>
  ArrayBuffer.isView(v) && !(v instanceof DataView);
export const vjs_inspect = Symbol("vjs_inspect");
