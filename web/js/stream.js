import {
  ByteLengthQueuingStrategy as ByteLengthQueuingStrategyPoly,
  CountQueuingStrategy as CountQueuingStrategyPoly,
  ReadableByteStreamController as ReadableByteStreamControllerPoly,
  ReadableStream as ReadableStreamPoly,
  ReadableStreamBYOBReader as ReadableStreamBYOBReaderPoly,
  ReadableStreamBYOBRequest as ReadableStreamBYOBRequestPoly,
  ReadableStreamDefaultController as ReadableStreamDefaultControllerPoly,
  ReadableStreamDefaultReader as ReadableStreamDefaultReaderPoly,
  TransformStream as TransformStreamPoly,
  TransformStreamDefaultController as TransformStreamDefaultControllerPoly,
  WritableStream as WritableStreamPoly,
  WritableStreamDefaultController as WritableStreamDefaultControllerPoly,
  WritableStreamDefaultWriter as WritableStreamDefaultWriterPoly,
} from "./polyfill/stream.js";
import { vjs_inspect } from "./util.js";

const state = {
  writable: "writable",
  readable: "readable",
};

class ReadableStream extends ReadableStreamPoly {
  [vjs_inspect]() {
    return {
      locked: this.locked,
      state: state.readable,
    };
  }
}

class WritableStream extends WritableStreamPoly {
  [vjs_inspect]() {
    return {
      locked: this.locked,
      state: state.writable,
    };
  }
}

class TransformStream extends TransformStreamPoly {
  [vjs_inspect]() {
    return {
      readable: { locked: this.readable.locked, state: state.readable },
      writable: { locked: this.writable.locked, state: state.writable },
    };
  }
}

class ReadableStreamDefaultReader extends ReadableStreamDefaultReaderPoly {
  [vjs_inspect]() {
    return {
      closed: this.closed,
      state: state.readable,
    };
  }
}

class ReadableStreamDefaultController
  extends ReadableStreamDefaultControllerPoly {
  [vjs_inspect]() {
    return {
      desiredSize: this.desiredSize,
      state: state.readable,
    };
  }
}

class WritableStreamDefaultWriter extends WritableStreamDefaultWriterPoly {
  [vjs_inspect]() {
    return {
      closed: this.closed,
      ready: this.ready,
      desiredSize: this.desiredSize,
      state: state.writable,
    };
  }
}

class WritableStreamDefaultController
  extends WritableStreamDefaultControllerPoly {
  [vjs_inspect]() {
    return {
      abortReason: this.abortReason,
      signal: this.signal,
    };
  }
}

class TransformStreamDefaultController
  extends TransformStreamDefaultControllerPoly {
  [vjs_inspect]() {
    return {
      desiredSize: this.desiredSize,
    };
  }
}

class ByteLengthQueuingStrategy extends ByteLengthQueuingStrategyPoly {
  [vjs_inspect]() {
    return {
      highWaterMark: this.highWaterMark,
      size: this.size,
    };
  }
}

class CountQueuingStrategy extends CountQueuingStrategyPoly {
  [vjs_inspect]() {
    return {
      highWaterMark: this.highWaterMark,
      size: this.size,
    };
  }
}
class ReadableStreamBYOBReader extends ReadableStreamBYOBReaderPoly {
  [vjs_inspect]() {
    return {
      closed: this.closed,
      state: state.readable,
    };
  }
}
class ReadableByteStreamController extends ReadableByteStreamControllerPoly {
  [vjs_inspect]() {
    return {
      byobRequest: this.byobRequest,
      desiredSize: this.desiredSize,
      state: state.readable,
    };
  }
}
class ReadableStreamBYOBRequest extends ReadableStreamBYOBRequestPoly {
  [vjs_inspect]() {
    return {
      view: this.view,
      state: state.readable,
    };
  }
}
globalThis.ReadableStream = ReadableStream;
globalThis.WritableStream = WritableStream;
globalThis.TransformStream = TransformStream;
globalThis.ReadableStreamDefaultReader = ReadableStreamDefaultReader;
globalThis.ReadableStreamDefaultController = ReadableStreamDefaultController;
globalThis.WritableStreamDefaultWriter = WritableStreamDefaultWriter;
globalThis.WritableStreamDefaultController = WritableStreamDefaultController;
globalThis.TransformStreamDefaultController = TransformStreamDefaultController;
globalThis.ByteLengthQueuingStrategy = ByteLengthQueuingStrategy;
globalThis.CountQueuingStrategy = CountQueuingStrategy;
globalThis.ReadableStreamBYOBReader = ReadableStreamBYOBReader;
globalThis.ReadableByteStreamController = ReadableByteStreamController;
globalThis.ReadableStreamBYOBRequest = ReadableStreamBYOBRequest;
