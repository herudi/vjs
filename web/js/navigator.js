import { vjs_inspect } from "./util.js";

const nav = globalThis.__navigator;

class Navigator {
  get userAgent() {
    return `vjs/${nav.version}`;
  }
  get platform() {
    return nav.platform;
  }
  get hardwareConcurrency() {
    return nav.nr_cpu;
  }
  [vjs_inspect]() {
    return {
      userAgent: this.userAgent,
      platform: this.platform,
      hardwareConcurrency: this.hardwareConcurrency,
    };
  }
}

globalThis.navigator = new Navigator();
