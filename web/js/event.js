/* Credit: https://www.npmjs.com/package/event-target-polyfill */
import { vjs_inspect } from "./util.js";

class Event {
  constructor(type, opts = {}) {
    this.bubbles = opts.bubbles ?? false;
    this.cancelable = opts.cancelable ?? false;
    this.composed = opts.composed ?? false;
    this.type = type;
  }
}
globalThis.Event = Event;
class CustomEvent extends Event {
  constructor(type, opts = {}) {
    super(type, opts);
    this.detail = opts.detail;
  }
}
globalThis.CustomEvent = CustomEvent;
class EventTarget {
  __listeners = void 0;
  constructor() {}
  get #listener() {
    return this.__listeners ??= new Map()
  }
  addEventListener(type, listener, options) {
    if (arguments.length < 2) {
      throw new TypeError(
        "TypeError: Failed to execute 'addEventListener' on 'EventTarget': 2 arguments required, but only " + arguments.length + " present."
      );
    }
    const __listeners = this.#listener;
    const actualType = type.toString();
    if (!__listeners.has(actualType)) {
      __listeners.set(actualType, new Map());
    }
    const listenersForType = __listeners.get(actualType);
    if (!listenersForType.has(listener)) {
      listenersForType.set(listener, options);
    }
  }
  removeEventListener(type, listener, _options) {
    if (arguments.length < 2) {
      throw new TypeError(
        "TypeError: Failed to execute 'addEventListener' on 'EventTarget': 2 arguments required, but only " + arguments.length + " present."
      );
    }
    const __listeners = this.#listener;
    const actualType = type.toString();
    if (__listeners.has(actualType)) {
      const listenersForType = __listeners.get(actualType);
      if (listenersForType.has(listener)) {
        listenersForType.delete(listener);
      }
    }
  }
  dispatchEvent(event) {
    if (!(event instanceof Event)) {
      throw new TypeError(
        "Failed to execute 'dispatchEvent' on 'EventTarget': parameter 1 is not of type 'Event'."
      );
    }
    const type = event.type;
    const __listeners = this.#listener;
    const listenersForType = __listeners.get(type);
    if (listenersForType) {
      for (const listnerEntry of listenersForType.entries()) {
        const listener = listnerEntry[0];
        const options = listnerEntry[1];
        try {
          if (typeof listener === "function") {
            listener.call(this, event);
          } else if (listener && typeof listener.handleEvent === "function") {
            listener.handleEvent(event);
          }
        } catch (err) {
          setTimeout(() => {
            throw err;
          });
        }
        if (options && options.once) {
          listenersForType.delete(listener);
        }
      }
    }
    return true;
  }

  [vjs_inspect](format) {
    return "EventTarget " + format({
      addEventListener: this.addEventListener,
      dispatchEvent: this.dispatchEvent,
      removeEventListener: this.removeEventListener,
    });
  }
}

globalThis.EventTarget = EventTarget;

const evt = new EventTarget();
globalThis.addEventListener = evt.addEventListener.bind(evt);
globalThis.dispatchEvent = evt.dispatchEvent.bind(evt);
globalThis.removeEventListener = evt.removeEventListener.bind(evt);