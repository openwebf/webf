/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

// Web Streams API polyfill implementation
// Based on: https://github.com/MattiasBuelens/web-streams-polyfill

export interface ReadableStreamDefaultController<R = any> {
  readonly desiredSize: number | null;
  close(): void;
  enqueue(chunk?: R): void;
  error(e?: any): void;
}

export interface ReadableStreamReader<R = any> {
  readonly closed: Promise<undefined>;
  cancel(reason?: any): Promise<void>;
  read(): Promise<ReadableStreamDefaultReadResult<R>>;
  releaseLock(): void;
}

export interface ReadableStreamDefaultReadResult<R> {
  done: boolean;
  value: R;
}

export interface WritableStreamDefaultController {
  readonly signal: AbortSignal;
  error(e?: any): void;
}

export interface WritableStreamDefaultWriter<W = any> {
  readonly closed: Promise<undefined>;
  readonly desiredSize: number | null;
  readonly ready: Promise<undefined>;
  abort(reason?: any): Promise<void>;
  close(): Promise<void>;
  releaseLock(): void;
  write(chunk?: W): Promise<void>;
}

export interface QueuingStrategy<T = any> {
  highWaterMark?: number;
  size?: (chunk: T) => number;
}

export interface UnderlyingSource<R = any> {
  start?(controller: ReadableStreamDefaultController<R>): any;
  pull?(controller: ReadableStreamDefaultController<R>): PromiseLike<void> | void;
  cancel?(reason?: any): PromiseLike<void> | void;
  type?: undefined;
}

export interface UnderlyingSink<W = any> {
  start?(controller: WritableStreamDefaultController): any;
  write?(chunk: W, controller: WritableStreamDefaultController): PromiseLike<void> | void;
  close?(controller: WritableStreamDefaultController): PromiseLike<void> | void;
  abort?(reason?: any): PromiseLike<void> | void;
  type?: undefined;
}

export interface Transformer<I = any, O = any> {
  start?(controller: TransformStreamDefaultController<O>): any;
  transform?(chunk: I, controller: TransformStreamDefaultController<O>): PromiseLike<void> | void;
  flush?(controller: TransformStreamDefaultController<O>): PromiseLike<void> | void;
  readableType?: undefined;
  writableType?: undefined;
}

export interface TransformStreamDefaultController<O = any> {
  readonly desiredSize: number | null;
  enqueue(chunk?: O): void;
  error(reason?: any): void;
  terminate(): void;
}

// ReadableStream implementation
export class ReadableStream<R = any> {
  private _state: 'readable' | 'closed' | 'errored';
  private _reader: ReadableStreamReader<R> | undefined;
  private _storedError: any;
  private _disturbed: boolean;
  private _readableStreamController: ReadableStreamDefaultController<R>;

  constructor(underlyingSource?: UnderlyingSource<R>, strategy?: QueuingStrategy<R>) {
    this._state = 'readable';
    this._reader = undefined;
    this._storedError = undefined;
    this._disturbed = false;
    
    const highWaterMark = strategy?.highWaterMark ?? 1;
    const size = strategy?.size ?? (() => 1);
    
    this._readableStreamController = new ReadableStreamDefaultControllerImpl<R>(
      this,
      underlyingSource,
      highWaterMark,
      size
    );
  }

  get locked(): boolean {
    return this._reader !== undefined;
  }

  cancel(reason?: any): Promise<void> {
    if (this._disturbed) {
      return Promise.reject(new TypeError('Stream has already been disturbed'));
    }
    this._disturbed = true;
    
    if (this._state === 'closed') {
      return Promise.resolve();
    }
    
    if (this._state === 'errored') {
      return Promise.reject(this._storedError);
    }

    return (this._readableStreamController as any).cancel(reason);
  }

  getReader(): ReadableStreamReader<R> {
    if (this.locked) {
      throw new TypeError('ReadableStream is locked');
    }
    
    this._reader = new ReadableStreamDefaultReaderImpl<R>(this);
    return this._reader;
  }

  pipeThrough<T>(transform: { readable: ReadableStream<T>; writable: WritableStream<R> }, options?: any): ReadableStream<T> {
    this.pipeTo(transform.writable, options);
    return transform.readable;
  }

  pipeTo(dest: WritableStream<R>, _options?: any): Promise<void> {
    return new Promise((resolve, reject) => {
      const reader = this.getReader();
      const writer = dest.getWriter();

      function pump(): Promise<void> {
        return reader.read().then(({ done, value }) => {
          if (done) {
            writer.close();
            resolve();
            return Promise.resolve();
          } else {
            return writer.write(value).then(pump);
          }
        });
      }

      pump().catch(reject);
    });
  }

  tee(): [ReadableStream<R>, ReadableStream<R>] {
    const reader = this.getReader();
    let teeState = {
      closedOrErrored: false,
      canceled1: false,
      canceled2: false,
      reason1: undefined,
      reason2: undefined
    };

    const stream1 = new ReadableStream<R>({
      start(controller) {
        return readAll(controller, 1);
      },
      cancel(reason) {
        teeState.canceled1 = true;
        teeState.reason1 = reason;
        if (teeState.canceled2) {
          return reader.cancel(reason);
        }
        return Promise.resolve();
      }
    });

    const stream2 = new ReadableStream<R>({
      start(controller) {
        return readAll(controller, 2);
      },
      cancel(reason) {
        teeState.canceled2 = true;
        teeState.reason2 = reason;
        if (teeState.canceled1) {
          return reader.cancel(reason);
        }
        return Promise.resolve();
      }
    });

    function readAll(controller: ReadableStreamDefaultController<R>, _streamNum: number): Promise<void> {
      return reader.read().then(({ done, value }) => {
        if (done) {
          controller.close();
          teeState.closedOrErrored = true;
          return Promise.resolve();
        }
        
        try {
          controller.enqueue(value);
        } catch (e) {
          controller.error(e);
          teeState.closedOrErrored = true;
          return Promise.resolve();
        }
        
        if (!teeState.closedOrErrored) {
          return readAll(controller, _streamNum);
        }
        return Promise.resolve();
      });
    }

    return [stream1, stream2];
  }

  async *values(): any {
    const reader = this.getReader();
    try {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        yield value;
      }
    } finally {
      reader.releaseLock();
    }
  }

  static from<R>(iterable: Iterable<R> | any): ReadableStream<R> {
    return new ReadableStream<R>({
      async start(controller) {
        try {
          for await (const chunk of iterable) {
            controller.enqueue(chunk);
          }
          controller.close();
        } catch (e) {
          controller.error(e);
        }
      }
    });
  }

  _setState(state: 'readable' | 'closed' | 'errored', error?: any): void {
    this._state = state;
    if (state === 'errored') {
      this._storedError = error;
    }
  }

  _releaseReader(): void {
    this._reader = undefined;
  }
}

// WritableStream implementation
export class WritableStream<W = any> {
  private _state: 'writable' | 'closed' | 'erroring' | 'errored';
  private _writer: WritableStreamDefaultWriter<W> | undefined;
  private _writableStreamController: WritableStreamDefaultController;

  constructor(underlyingSink?: UnderlyingSink<W>, strategy?: QueuingStrategy<W>) {
    this._state = 'writable';
    this._writer = undefined;
    
    const highWaterMark = strategy?.highWaterMark ?? 1;
    const size = strategy?.size ?? (() => 1);
    
    this._writableStreamController = new WritableStreamDefaultControllerImpl<W>(
      this,
      underlyingSink,
      highWaterMark,
      size
    );
  }

  get locked(): boolean {
    return this._writer !== undefined;
  }

  abort(reason?: any): Promise<void> {
    if (this._state === 'closed' || this._state === 'errored') {
      return Promise.resolve();
    }
    
    this._state = 'erroring';
    
    return (this._writableStreamController as any).abort(reason);
  }

  close(): Promise<void> {
    if (this._state !== 'writable') {
      return Promise.reject(new TypeError('Stream is not in writable state'));
    }
    
    return (this._writableStreamController as any).close();
  }

  getWriter(): WritableStreamDefaultWriter<W> {
    if (this.locked) {
      throw new TypeError('WritableStream is locked');
    }
    
    this._writer = new WritableStreamDefaultWriterImpl<W>(this);
    return this._writer;
  }

  _setState(state: 'writable' | 'closed' | 'erroring' | 'errored', _error?: any): void {
    this._state = state;
  }

  _releaseWriter(): void {
    this._writer = undefined;
  }
}

// TransformStream implementation
export class TransformStream<I = any, O = any> {
  private _readable: ReadableStream<O>;
  private _writable: WritableStream<I>;

  constructor(transformer?: Transformer<I, O>, writableStrategy?: QueuingStrategy<I>, readableStrategy?: QueuingStrategy<O>) {
    const transformStreamController = new TransformStreamDefaultControllerImpl<O>();
    
    this._readable = new ReadableStream<O>({
      start(controller) {
        transformStreamController._setReadableController(controller);
        return transformer?.start?.(transformStreamController);
      },
      pull(controller) {
        return Promise.resolve();
      },
      cancel(reason) {
        transformStreamController.error(reason);
        return Promise.resolve();
      }
    }, readableStrategy);

    this._writable = new WritableStream<I>({
      start(_controller) {
        return Promise.resolve();
      },
      write(chunk, _controller) {
        return transformer?.transform?.(chunk, transformStreamController);
      },
      close(_controller) {
        return Promise.resolve(transformer?.flush?.(transformStreamController)).then(() => {
          transformStreamController._getReadableController().close();
        });
      },
      abort(reason) {
        transformStreamController.error(reason);
        return Promise.resolve();
      }
    }, writableStrategy);
  }

  get readable(): ReadableStream<O> {
    return this._readable;
  }

  get writable(): WritableStream<I> {
    return this._writable;
  }
}

// Controller implementations
class ReadableStreamDefaultControllerImpl<R> implements ReadableStreamDefaultController<R> {
  private _stream: ReadableStream<R>;
  private _underlyingSource: UnderlyingSource<R> | undefined;
  private _highWaterMark: number;
  private _size: (chunk: R) => number;
  private _queue: Array<{ chunk: R; size: number }> = [];
  private _queueTotalSize: number = 0;
  private _started: boolean = false;
  private _closeRequested: boolean = false;
  private _pullAgain: boolean = false;
  private _pulling: boolean = false;

  constructor(
    stream: ReadableStream<R>,
    underlyingSource?: UnderlyingSource<R>,
    highWaterMark?: number,
    size?: (chunk: R) => number
  ) {
    this._stream = stream;
    this._underlyingSource = underlyingSource;
    this._highWaterMark = highWaterMark ?? 1;
    this._size = size ?? (() => 1);
    
    Promise.resolve(underlyingSource?.start?.(this)).then(() => {
      this._started = true;
      this._callPullIfNeeded();
    }).catch(e => {
      this.error(e);
    });
  }

  get desiredSize(): number | null {
    if (this._stream['_state'] === 'errored') {
      return null;
    }
    if (this._stream['_state'] === 'closed') {
      return 0;
    }
    return this._highWaterMark - this._queueTotalSize;
  }

  close(): void {
    if (this._closeRequested) {
      throw new TypeError('Stream has already been closed');
    }
    this._closeRequested = true;
    
    if (this._queue.length === 0) {
      this._stream._setState('closed');
    }
  }

  enqueue(chunk?: R): void {
    if (this._closeRequested) {
      throw new TypeError('Stream is closed');
    }
    if (this._stream['_state'] !== 'readable') {
      throw new TypeError('Stream is not readable');
    }
    
    if (chunk !== undefined) {
      const size = this._size(chunk);
      this._queue.push({ chunk, size });
      this._queueTotalSize += size;
    }
    
    this._callPullIfNeeded();
  }

  error(e?: any): void {
    this._stream._setState('errored', e);
  }

  cancel(reason?: any): Promise<void> {
    this._queue.length = 0;
    this._queueTotalSize = 0;
    return Promise.resolve(this._underlyingSource?.cancel?.(reason));
  }

  _dequeue(): { chunk: R; size: number } | undefined {
    if (this._queue.length === 0) {
      return undefined;
    }
    
    const item = this._queue.shift()!;
    this._queueTotalSize -= item.size;
    
    if (this._closeRequested && this._queue.length === 0) {
      this._stream._setState('closed');
    }
    
    return item;
  }

  private _callPullIfNeeded(): void {
    if (!this._started || this._pulling || this._closeRequested) {
      return;
    }
    
    if (this._queueTotalSize < this._highWaterMark) {
      this._pulling = true;
      Promise.resolve(this._underlyingSource?.pull?.(this)).then(() => {
        this._pulling = false;
        if (this._pullAgain) {
          this._pullAgain = false;
          this._callPullIfNeeded();
        }
      }).catch(e => {
        this.error(e);
      });
    }
  }
}

class WritableStreamDefaultControllerImpl<W> implements WritableStreamDefaultController {
  private _stream: WritableStream<W>;
  private _underlyingSink: UnderlyingSink<W> | undefined;
  private _abortController: AbortController;

  constructor(
    stream: WritableStream<W>,
    underlyingSink?: UnderlyingSink<W>,
    _highWaterMark?: number,
    _size?: (chunk: W) => number
  ) {
    this._stream = stream;
    this._underlyingSink = underlyingSink;
    this._abortController = new AbortController();
    
    Promise.resolve(underlyingSink?.start?.(this)).catch(e => {
      this.error(e);
    });
  }

  get signal(): AbortSignal {
    return this._abortController.signal;
  }

  error(e?: any): void {
    this._stream._setState('errored', e);
  }

  async write(chunk: W): Promise<void> {
    return this._underlyingSink?.write?.(chunk, this);
  }

  async close(): Promise<void> {
    await this._underlyingSink?.close?.(this);
    this._stream._setState('closed');
  }

  async abort(reason?: any): Promise<void> {
    this._abortController.abort(reason);
    await this._underlyingSink?.abort?.(reason);
    this._stream._setState('errored', reason);
  }
}

class TransformStreamDefaultControllerImpl<O> implements TransformStreamDefaultController<O> {
  private _readableController: ReadableStreamDefaultController<O> | undefined;

  get desiredSize(): number | null {
    return this._readableController?.desiredSize ?? null;
  }

  enqueue(chunk?: O): void {
    this._readableController?.enqueue(chunk);
  }

  error(reason?: any): void {
    this._readableController?.error(reason);
  }

  terminate(): void {
    this._readableController?.close();
  }

  _setReadableController(controller: ReadableStreamDefaultController<O>): void {
    this._readableController = controller;
  }

  _getReadableController(): ReadableStreamDefaultController<O> {
    return this._readableController!;
  }
}

// Reader implementations
class ReadableStreamDefaultReaderImpl<R> implements ReadableStreamReader<R> {
  private _stream: ReadableStream<R>;
  private _closedPromise: Promise<undefined>;
  private _closedResolve: ((value: undefined) => void) | undefined;

  constructor(stream: ReadableStream<R>) {
    this._stream = stream;
    this._closedPromise = new Promise((resolve) => {
      this._closedResolve = resolve;
    });
  }

  get closed(): Promise<undefined> {
    return this._closedPromise;
  }

  cancel(reason?: any): Promise<void> {
    this.releaseLock();
    return this._stream.cancel(reason);
  }

  read(): Promise<ReadableStreamDefaultReadResult<R>> {
    if (this._stream['_state'] === 'closed') {
      return Promise.resolve({ done: true, value: undefined as any });
    }
    
    if (this._stream['_state'] === 'errored') {
      return Promise.reject(this._stream['_storedError']);
    }
    
    const controller = this._stream['_readableStreamController'];
    const item = (controller as any)._dequeue();
    
    if (item) {
      return Promise.resolve({ done: false, value: item.chunk });
    }
    
    return Promise.resolve({ done: true, value: undefined as any });
  }

  releaseLock(): void {
    if (this._stream['_reader'] === this) {
      this._stream._releaseReader();
      if (this._closedResolve) {
        this._closedResolve(undefined);
      }
    }
  }
}

// Writer implementations
class WritableStreamDefaultWriterImpl<W> implements WritableStreamDefaultWriter<W> {
  private _stream: WritableStream<W>;
  private _closedPromise: Promise<undefined>;
  private _closedResolve: ((value: undefined) => void) | undefined;
  private _readyPromise: Promise<undefined>;

  constructor(stream: WritableStream<W>) {
    this._stream = stream;
    this._closedPromise = new Promise((resolve) => {
      this._closedResolve = resolve;
    });
    this._readyPromise = Promise.resolve(undefined);
  }

  get closed(): Promise<undefined> {
    return this._closedPromise;
  }

  get desiredSize(): number | null {
    return 1; // Simplified implementation
  }

  get ready(): Promise<undefined> {
    return this._readyPromise;
  }

  abort(reason?: any): Promise<void> {
    this.releaseLock();
    return this._stream.abort(reason);
  }

  close(): Promise<void> {
    this.releaseLock();
    return this._stream.close() as Promise<void>;
  }

  releaseLock(): void {
    if (this._stream['_writer'] === this) {
      this._stream._releaseWriter();
      if (this._closedResolve) {
        this._closedResolve(undefined);
      }
    }
  }

  write(chunk?: W): Promise<void> {
    return (this._stream['_writableStreamController'] as any).write(chunk!);
  }
}