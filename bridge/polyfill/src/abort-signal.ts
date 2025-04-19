const SECRET = {};

export interface AbortSignalInterface extends EventTarget {
  readonly aborted: boolean;
  onabort: ((this: AbortSignalInterface, ev: Event) => any) | null;
  addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
  removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
  dispatchEvent(event: Event): boolean;
}

export interface AbortControllerInterface {
  readonly signal: AbortSignalInterface;
  abort(): void;
}

// @ts-ignore
export class _AbortSignal extends EventTarget {
  public _aborted: boolean;

  get aborted() {
    return this._aborted;
  }

  constructor(secret: any) {
    super();
    if (secret !== SECRET) {
      throw new TypeError("Illegal constructor.");
    }
    this._aborted = false;
  }

  private _onabort: any;
  get onabort() {
    return this._aborted;
  }
  set onabort(callback: any) {
    const existing = this._onabort;
    if (existing) {
      this.removeEventListener("abort", existing);
    }
    this._onabort = callback;
    this.addEventListener("abort", callback);
  }
}

export class _AbortController {
  public _signal: _AbortSignal;
  constructor() {
    this._signal = new _AbortSignal(SECRET);
  }

  get signal() {
    return this._signal;
  }

  abort() {
    const signal = this.signal;
    if (!signal.aborted) {
      signal._aborted = true;
      signal.dispatchEvent(new Event("abort"));
    }
  }
}


