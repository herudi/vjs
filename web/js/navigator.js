import { vjs_inspect } from "./util.js";

const nav = globalThis.__navigator;

class Navigator {
  get userAgent() {
    return nav.userAgent;
  }
  get platform() {
    return nav.platform;
  }
  get hardwareConcurrency() {
    return nav.hardwareConcurrency;
  }
  [vjs_inspect]() {
    return nav;
  }
}

globalThis.navigator = new Navigator();
