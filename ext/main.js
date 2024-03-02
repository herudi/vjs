import "./timer.js";
import "./console.js";

// remove global __bootstrap
globalThis.__bootstrap = void 0;
const window = globalThis;
globalThis.window = window;
