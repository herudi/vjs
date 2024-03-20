import { vjs_inspect } from "./util.js";

const { get_navigator } = globalThis.__bootstrap;

class Navigator {
  #nav;
  #getNav() {
    return this.#nav ??= get_navigator();
  }
  get userAgent() {
    return this.#getNav().userAgent;
  }
  get platform() {
    return this.#getNav().platform;
  }
  get hardwareConcurrency() {
    return this.#getNav().hardwareConcurrency;
  }
  [vjs_inspect](format) {
    return "Navigator " + format(this.#getNav());
  }
}

globalThis.navigator = new Navigator();
