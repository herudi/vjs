import { vjs_inspect } from "./util.js";

const inspector_event = (obj) => ({
  type: obj.type,
  target: obj.target,
  currentTarget: obj.currentTarget,
  eventPhase: obj.eventPhase,
  cancelBubble: obj.cancelBubble,
  bubbles: obj.bubbles,
  cancelable: obj.cancelable,
  defaultPrevented: obj.defaultPrevented,
  composed: obj.composed,
  timeStamp: obj.timeStamp,
  srcElement: obj.srcElement,
  returnValue: obj.returnValue,
  NONE: obj.NONE,
  CAPTURING_PHASE: obj.CAPTURING_PHASE,
  AT_TARGET: obj.AT_TARGET,
  BUBBLING_PHASE: obj.BUBBLING_PHASE,
  isTrusted: obj.isTrusted,
});

class Event {
  #type = void 0;
  #opts = void 0;
  __currentTarget = void 0;
  constructor(type, opts = {}) {
    this.#type = type;
    this.#opts = opts;
  }

  get bubbles() {
    return this.#opts.bubbles ?? false;
  }

  get cancelable() {
    return this.#opts.cancelable ?? false;
  }

  get composed() {
    return this.#opts.composed ?? false;
  }

  get type() {
    return this.#type;
  }

  get currentTarget() {
    return this.__currentTarget;
  }

  get target() {
    return this.__currentTarget;
  }

  get timeStamp() {
    return 0;
  }

  get returnValue() {
    return true;
  }
  get eventPhase() {
    return 2;
  }
  get srcElement() {
    return this.target;
  }
  get defaultPrevented() {
    return false;
  }
  get isTrusted() {
    return false;
  }
  get cancelBubble() {
    return false;
  }
  get NONE() {
    return 0;
  }
  get CAPTURING_PHASE() {
    return 1;
  }
  get AT_TARGET() {
    return 2;
  }
  get BUBBLING_PHASE() {
    return 3;
  }
  stopPropagation() {}
  stopImmediatePropagation() {}
  preventDefault() {}
  initEvent(type, bubbles, cancelable) {
    this.#opts.bubbles = bubbles;
    this.#opts.cancelable = cancelable;
    this.#type = type;
  }
  composedPath() {
    return [this.__currentTarget];
  }

  [vjs_inspect](format) {
    return "Event " + format(inspector_event(this));
  }
}
globalThis.Event = Event;
class CustomEvent extends Event {
  #detail = void 0;
  constructor(type, opts = {}) {
    super(type, opts);
    this.#detail = opts.detail;
  }
  get detail() {
    return this.#detail;
  }

  [vjs_inspect](format) {
    return "CustomEvent " + format({
      ...inspector_event(this),
      detail: this.detail,
    });
  }
}
globalThis.CustomEvent = CustomEvent;

/* Credit: https://www.npmjs.com/package/event-target-polyfill */
class EventTarget {
  __listeners = void 0;
  constructor() {}
  get #listener() {
    return this.__listeners ??= new Map();
  }
  addEventListener(type, listener, options) {
    if (arguments.length < 2) {
      throw new TypeError(
        "TypeError: Failed to execute 'addEventListener' on 'EventTarget': 2 arguments required, but only " +
          arguments.length + " present.",
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
        "TypeError: Failed to execute 'addEventListener' on 'EventTarget': 2 arguments required, but only " +
          arguments.length + " present.",
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
        "Failed to execute 'dispatchEvent' on 'EventTarget': parameter 1 is not of type 'Event'.",
      );
    }
    event.__currentTarget = this;
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
    return "EventTarget " + format({});
  }
}

globalThis.EventTarget = EventTarget;

const evt = new EventTarget();
globalThis.addEventListener = evt.addEventListener.bind(evt);
globalThis.dispatchEvent = evt.dispatchEvent.bind(evt);
globalThis.removeEventListener = evt.removeEventListener.bind(evt);
