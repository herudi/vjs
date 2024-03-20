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
  [vjs_inspect](format) {
    return "ReadableStream " + format({
      locked: this.locked,
      state: state.readable,
    });
  }
}

class WritableStream extends WritableStreamPoly {
  [vjs_inspect](format) {
    return "WritableStream " + format({
      locked: this.locked,
      state: state.writable,
    });
  }
}

class TransformStream extends TransformStreamPoly {
  [vjs_inspect](format) {
    return "TransformStream " + format({
      readable: { locked: this.readable.locked, state: state.readable },
      writable: { locked: this.writable.locked, state: state.writable },
    });
  }
}

class ReadableStreamDefaultReader extends ReadableStreamDefaultReaderPoly {
  [vjs_inspect](format) {
    return "ReadableStreamDefaultReader " + format({
      closed: this.closed,
      state: state.readable,
    });
  }
}

class ReadableStreamDefaultController
  extends ReadableStreamDefaultControllerPoly {
  [vjs_inspect](format) {
    return "ReadableStreamDefaultController " + format({
      desiredSize: this.desiredSize,
      state: state.readable,
    });
  }
}

class WritableStreamDefaultWriter extends WritableStreamDefaultWriterPoly {
  [vjs_inspect](format) {
    return "WritableStreamDefaultWriter " + format({
      closed: this.closed,
      ready: this.ready,
      desiredSize: this.desiredSize,
      state: state.writable,
    });
  }
}

class WritableStreamDefaultController
  extends WritableStreamDefaultControllerPoly {
  [vjs_inspect](format) {
    return "WritableStreamDefaultController " + format({
      abortReason: this.abortReason,
      signal: this.signal,
    });
  }
}

class TransformStreamDefaultController
  extends TransformStreamDefaultControllerPoly {
  [vjs_inspect](format) {
    return "TransformStreamDefaultController " + format({
      desiredSize: this.desiredSize,
    });
  }
}

class ByteLengthQueuingStrategy extends ByteLengthQueuingStrategyPoly {
  [vjs_inspect](format) {
    return "ByteLengthQueuingStrategy " + format({
      highWaterMark: this.highWaterMark,
      size: this.size,
    });
  }
}

class CountQueuingStrategy extends CountQueuingStrategyPoly {
  [vjs_inspect](format) {
    return "CountQueuingStrategy " + format({
      highWaterMark: this.highWaterMark,
      size: this.size,
    });
  }
}
class ReadableStreamBYOBReader extends ReadableStreamBYOBReaderPoly {
  [vjs_inspect](format) {
    return "ReadableStreamBYOBReader " + format({
      closed: this.closed,
      state: state.readable,
    });
  }
}
class ReadableByteStreamController extends ReadableByteStreamControllerPoly {
  [vjs_inspect](format) {
    return "ReadableByteStreamController " + format({
      byobRequest: this.byobRequest,
      desiredSize: this.desiredSize,
      state: state.readable,
    });
  }
}
class ReadableStreamBYOBRequest extends ReadableStreamBYOBRequestPoly {
  [vjs_inspect](format) {
    return "ReadableStreamBYOBRequest " + format({
      view: this.view,
      state: state.readable,
    });
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
