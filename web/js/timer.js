import * as os from "os";

globalThis.setTimeout = os.setTimeout;
globalThis.clearTimeout = os.clearTimeout;

const timers = new Map();
globalThis.setInterval = (cb, interval) => {
  const timer = {};
  const state = { enabled: true };
  timers.set(timer, state);
  const fn = () => {
    os.setTimeout(() => {
      if (!state.enabled) {
        return;
      }
      cb();
      fn();
    }, interval);
  };
  fn();
  return timer;
};

globalThis.clearInterval = (timer) => {
  const state = timers.get(timer);
  if (state === undefined) {
    return false;
  }
  state.enabled = false;
  timers.delete(timer);
  return true;
};
