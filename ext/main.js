import "./timer.js";
import "./console.js";
import "./url.js";
import "./encoding.js";

// remove global __bootstrap
globalThis.__bootstrap = void 0;
if (typeof window === "undefined") {
  globalThis.window = globalThis;
}
